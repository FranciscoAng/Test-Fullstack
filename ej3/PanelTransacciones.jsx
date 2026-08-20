import {useEffect, useReducer } from 'react';
// Construye este componente desde cero.
// La funcion mockFetch esta disponible (simula una API REST):
 
const NO_ITEMS = 10;
const delay = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

//Funcion que genera registros aleatorios, los filtra y regresa segun la paginacion. Simula latencia del servidor para mostrar que esta cargando.
async function mockFetch(page = 1, estado = 'todas') {
    await delay(600);

    const RAND_LEN = Math.floor(12 + Math.random() * 50)
    const MOCK_DATA = Array.from({ length: RAND_LEN }, (_, index) => {
        const id = index + 1;
        const statuses = ['pendiente', 'aprobado', 'rechazado'];
        return {
            id: `ID${1000 + id}`,
            cliente: `Cliente ${id}`,
            monto: `$${(Math.random() * 500 + 50).toFixed(2)}`,
            estado: statuses[Math.floor(Math.random() * statuses.length)],
            fecha: new Date(2026, 0, (id % 28) + 1).toLocaleDateString('es-ES')
        };
    });
    
    const filtered = estado === 'todas'? MOCK_DATA : MOCK_DATA.filter((item) => item.estado === estado);
    const totalCount = filtered.length;
    const startIndex = (page - 1) * NO_ITEMS;
    const paginatedData = filtered.slice(startIndex, startIndex + NO_ITEMS);
    return {data: paginatedData, total: totalCount, pages: Math.ceil(totalCount/NO_ITEMS)}
  // Retorna: { data: [...transacciones], total: number, pages: number }
  // Cada transaccion: { id, cliente, monto, estado, fecha }
  // estado puede ser: 'pendiente' | 'aprobado' | 'rechazado' | 'todas'
}

//Funcion para exportar un array en CSV
function exportCSV(arr){
    const array = [Object.keys(arr[0])].concat(arr);
    let csvContent = "data:text/csv;charset=utf-8," + array.map(it => {
        return Object.values(it).toString();
    }).join('\n');
    var encodedUri = encodeURI(csvContent);
    window.open(encodedUri);
}

// Funcion para utilizar AbortController sin modificar la firma de mockFetch
function makeCancelable(promise, signal) {
  return new Promise((resolve, reject) => {
    // Escuchar si el controller se aborta
    signal.addEventListener('abort', () => {
      reject(new DOMException('Aborted', 'AbortError'));
    });

    // Ejecutar la promesa original
    promise.then(resolve).catch(reject);
  });
}

// ENTREGABLE: export default function PanelTransacciones() { ... }
export default function PanelTransacciones() {
    const initialState = {
        data: [],
        totalCount: 0,
        totalPgs: 1,
        loading: true,
        error: null,
        filter: 'todas',
        currentPage: 1,
    };

    function tableReducer(state, action) {
        switch (action.type) {
            case 'FETCH_START':
            return {
                ...state,
                loading: true,
                error: null,
            };
            case 'FETCH_SUCCESS':
            return {
                ...state,
                loading: false,
                data: action.payload.data,
                totalCount: action.payload.total,
                totalPages: action.payload.pages,
            };
            case 'FETCH_ERROR':
            return {
                ...state,
                loading: false,
                error: action.payload,
            };
            case 'SET_FILTER':
            return {
                ...state,
                estadoFilter: action.payload,
                currentPage: 1, // Reinicia a la página 1 al cambiar filtro
            };
            case 'SET_PAGE':
            return {
                ...state,
                currentPage: action.payload,
            };
            default:
            return state;
        }
    }

    const [state, dispatch] = useReducer(tableReducer, initialState);

    const {
        data,
        totalCount,
        totalPgs,
        loading,
        error,
        estadoFilter,
        currentPage,
    } = state;

    useEffect(() => {
        // 1. Crear una instancia de AbortController
        const controller = new AbortController();

        const loadData = async () => {
            dispatch({ type: 'FETCH_START' });
            try {
                const response = await makeCancelable(
                    mockFetch(currentPage, estadoFilter),
                    controller.signal
                );
                
                // Si no fue cancelada, despachamos el éxito
                dispatch({ type: 'FETCH_SUCCESS', payload: response });
            } catch (err) {
            
            if (err.name === 'AbortError') {
                console.log("Abort");
                return;
            }
            dispatch({ type: 'FETCH_ERROR', payload: err.message || 'Error al cargar los datos'});
            }
        };

        loadData();

        // 4. Función de limpieza: Aborta la petición pendiente si cambia el filtro/página o se desmonta el componente
        return () => {
        controller.abort();
        };
    }, [currentPage, estadoFilter]);

    //Cambio de filtro
    const handleFilterChange = (newFilter) => {
        dispatch({ type: 'SET_FILTER', payload: newFilter });
    };

    return (
        <>
            <div>
                {['todas', 'pendiente', 'aprobado', 'rechazado'].map((status) => (
                <button
                    key={status}
                    //disabled={loading}
                    onClick={() => handleFilterChange(status)}
                >
                    {status}
                </button>
                ))}
            </div>

            {/* Table */}
            <div>
                <table>
                <thead>
                    <tr>
                    <th>Monto</th>
                    <th>Cliente</th>
                    <th>ID</th>
                    <th>Estado</th>
                    <th>Fecha</th>
                    </tr>
                </thead>
                <tbody>
                    {loading ? (
                    <tr>
                        <td colSpan="5">
                            <div>
                                <span>Cargando datos del servidor...</span>
                            </div>
                        </td>
                    </tr>
                    ) : data.length > 0 ? (
                    data.map((row) => (
                        <tr key={row.id}>
                            <td>{row.id}</td>
                            <td>{row.cliente}</td>
                            <td>{row.monto}</td>
                            <td>{row.estado}</td>
                            <td>{row.fecha}</td>
                        </tr>
                    ))
                    ) : (
                    <tr>
                        <td>
                        No se encontraron registros
                        </td>
                    </tr>
                    )}
                </tbody>
                </table>
            </div>
            <span>Página {currentPage} de {totalPgs} ({totalCount} resultados)</span>
            <div>
                <button
                    onClick={() => dispatch({type: 'SET_PAGE', payload: Math.max(currentPage - 1, 1)})}
                    disabled={currentPage === 1 || loading}
                >
                    Anterior
                </button>
                <button
                    onClick={() => dispatch({type: 'SET_PAGE', payload: Math.min(currentPage + 1, totalPgs)})}
                    disabled={currentPage === totalPgs || loading}
                >
                    Siguiente
                </button>
            </div>
            <div>
                <button onClick={() => exportCSV(data)}>Exportar CSV</button>
            </div>
        </>
    );
}