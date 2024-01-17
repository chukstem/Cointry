
String format(String number, String decimal){
   if(number.contains(".")){
    number=number.replaceAll(",", "");
    var part1=number.split(".")[0];
    var part2=number.split(".")[1].length > int.parse(decimal)? number.split(".")[1].substring(0, int.parse(decimal)) : number.split(".")[1];
    number=part1+"."+part2;
   }
   return number.replaceAll(",", "").length > 10? number.replaceAll(",", "").substring(0, 10) : number.replaceAll(",", "");
}
