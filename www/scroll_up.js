Shiny.addCustomMessageHandler("scrollCallback",
                          function(msg) {
console.log("aCMH" + msg)
var objDiv = document.getElementById("randomOutput");
objDiv.scrollTop = objDiv.scrollHeight - objDiv.clientHeight;
console.dir(objDiv)
console.log("sT:"+objDiv.scrollTop+" = sH:"+objDiv.scrollHeight+" cH:"+objDiv.clientHeight)
}
);