function rad=dms2rad(dms)%¶È·ÖÃë£¨dd.mmss£©£­>»¡¶È
 
 degree = fix(dms);
 mimute = fix((dms-degree)*100);
 second = (dms-degree-mimute/100)*10000;
 rad = (degree+mimute/60+second/3600)*pi/180;
end