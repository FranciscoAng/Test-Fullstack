<?php
// Archivo: ejercicio2/TransaccionController.php
// Este controlador fue escrito por un desarrollador junior.
// Contiene exactamente 5 vulnerabilidades / bugs. Identifica y corrige cada uno.
// Escribe un comentario encima de cada problema explicando que falla y por que.
 
namespace App\Http\Controllers;
 
use App\Models\Transaccion;
use App\Models\Cliente;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
 
class TransaccionController extends Controller
{
    // Bug 1
    public function index(Request $request)
    {
        //Hace falta validar que se ingresó el ID de forma correcta (entero y no nulo)
        $validated = $request->validate([
            'cliente_id' => 'required|integer',
        ]);
        $clienteId = $request->input('cliente_id');
 
        // Bug 2 Bulnerable por SQL Injection al solo concatenar la solicitud.
        $rows = DB::table('transacciones')->where('cliente_id', $clienteId)->get();
        //O bien
        $sql = "SELECT * FROM transacciones WHERE cliente_id = :id";
        $stmt = $pdo->prepare($sql);
        $stmt->execute(array(
            ':id' => $clienteId
        ));
        $rows = $stmt->fetch(PDO::FETCH_ASSOC);
 
        return response()->json($rows);
    }
 
    public function store(Request $request)
    {
        // Bug 3 y Bug 4
        //Es un problema de seguridad el insertar un request completo sin validación,
        // pues se puede enviar desde el cliente campos que no se habían definido en el formulario.
        // es importante hacer la validación explicita y permitir solo los campos que fueron validados
        $validado = $request->validate([
            'cliente_id' => 'required|integer|exists:clientes,id',
            'monto' => 'required|integer',
            'concepto' => 'required|string|max:255'
        ]);
        $t = Transaccion::create($datosValidados);
        return response()->json($t, 201);
    }
 
    public function resumenClientes()
    {
        $clientes = Cliente::all();

        // Bug 5 Usar Eloquent eager loading para evitar N+1 usando foreach ya que se ha definido el modelo Cliente
        $clientes = Cliente::with('transacciones')->get();
 
        return response()->json($clientes);
    }
}
