import Component from '@glimmer/component';
import { service } from '@ember/service';

export default class TypesListTablePagination extends Component {
	@service type;
	
	getCount = (i)=>{
		return i.length;
	}
}
