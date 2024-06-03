
import 'package:aquila_hundi/store/app.state.dart';
import 'package:redux/redux.dart';


Middleware<AppState> getAuth(repo) {
	return (Store<AppState> store, action, NextDispatcher dispatch) async {
	dispatch(action);
	try {
		// TODO: Write here your middleware logic and api calls
	} catch (error) {
		// TODO: API Error handling
		print(error);
	}
	};
}
	