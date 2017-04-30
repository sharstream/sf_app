function getImages(item, callback){
	var imageData = [];
	if (item.allowPreview === true && item.files && item.files.length > 0) {
		var count = 0;
		for (var j = 0; j < item.files.length; j++) {
			(function(file){
				if (file.fileName === "assetPreviewThumb" && file.contentType === "image/png") {
					var self = this;
					var xhr = new XMLHttpRequest();
					xhr.onreadystatechange = function(){
						if (xhr.readyState === 4) {
							if (xhr.status > 199 && xhr.status < 300) {
								var blob = Blob([xhr.response],{
									type: 'image/png'
								});
								var reader = new FileReader();
								reader.id = item.id;
								reader.onload = function(e){
									var returnedURL = e.target.result;
									var returnedBase64 = returnedURL.replace(/^[^,]+,/, '');
									imageData.push("data:image/png;base64," + returnedBase64);
									count++;
									if (count >= item.files.length && callback instanceof Function) {
										callback(imageData);
									}
								};
								reader.readAsDataURL(blob); //Convert the blob from clipboard to base64

							} else {
								console.error(xhr.responseText);
							}
						}
					};
					xhr.open('GET', force.oauth.instance_url + file.url, true);
					xhr.responseType = 'arraybuffer';
					xhr.setRequestHeader("Authorization", "Bearer " + force.oauth.access_token);
					xhr.send(undefined);
				}
			})(item.files[j]);
		}
	} else{
		if (callback instanceof Function) {
			callback(null);
		}
	}
}