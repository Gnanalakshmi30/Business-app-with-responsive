
import 'package:redux/redux.dart';
import 'package:redux_thunk/redux_thunk.dart';

import './app.state.dart';

List<Middleware<AppState>> appMiddleware() {
//   final Middleware<AppState> _login = login(_repo);

return [
    // TypedMiddleware<AppState, LoginAction>(_login),
    thunkMiddleware,
]; 
}
	