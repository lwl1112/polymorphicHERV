function QueryString()
{
	var name,value,i;
	var str=location.href;
	var num=str.indexOf("?")
	str=str.substr(num+1);
	var arrtmp=str.split("&"); 

	for(i=0;i < arrtmp.length;i++){
		num=arrtmp[i].indexOf("=");
		if(num>0){
			name=arrtmp[i].substring(0,num);//parameter name
			value=arrtmp[i].substr(num+1);//parameter value
			this[name]=value; 
		}
	}
	
}

var Request=new QueryString();