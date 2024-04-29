--------------------------------------------------------
--  DDL for Package Body CCT_COLLECTION_UTIL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CCT_COLLECTION_UTIL_PUB" as
/* $Header: cctcollb.pls 115.4 2003/02/19 02:31:54 svinamda noship $ */

FUNCTION	 Get(
     p_key_value_varr  IN cct_keyvalue_varr
    ,p_key             IN VARCHAR2
    ,x_key_exists Out NOCOPY VARCHAR2
 ) return varchar2 IS

   l_key varchar2(4000);
   l_value varchar2(4000) := '';
   l_key_value_varr cct_keyvalue_varr;
   i BINARY_INTEGER;
 begin
    x_key_exists := G_FALSE;
    If (p_key IS NULL) Then
        return '';
    End If ;
    i := p_key_value_varr.FIRST;
    while (i <= p_key_value_varr.LAST) LOOP
	--dbms_output.put_line (' Value of varray is ' || p_key_value_varr(i));
    l_key := p_key_value_varr(i);
    i := p_key_value_varr.NEXT(i);
    If UPPER(l_key) = UPPER(p_key) then
        x_key_exists := G_TRUE;
        l_value := p_key_value_varr(i);
        return l_value;
    End If ;
    i := p_key_value_varr.NEXT(i);
    END LOOP;
    return l_value;
    EXCEPTION
      WHEN OTHERS THEN
      return l_value;
END Get;

FUNCTION	 Put(
     p_key_value_varr  IN OUT NOCOPY cct_keyvalue_varr
    ,p_key             IN VARCHAR2
    ,p_value             IN VARCHAR2
 ) return varchar2 IS

   l_key varchar2(4000);
   l_value varchar2(4000) := '';
   l_key_value_varr cct_keyvalue_varr;
   i BINARY_INTEGER;
 begin
    If ((p_key IS NULL) OR (p_value IS NULL)) Then
        RAISE NULL_POINTER_EXCEPTION;
    End If ;
    i := p_key_value_varr.FIRST;
    while (i <= p_key_value_varr.LAST) LOOP
--	dbms_output.put_line (' Value of varray is ' || p_key_value_varr(i));
    l_key := p_key_value_varr(i);
    i := p_key_value_varr.NEXT(i);
    If UPPER(l_key) = UPPER(p_key)  then
 --       x_oper_succeeded := 'Y';
        l_value := p_key_value_varr(i);
        p_key_value_varr(i) := p_value;
        return l_value;
    End If ;
    i := p_key_value_varr.NEXT(i);
    END LOOP;
    p_key_value_varr.EXTEND();
    i := p_key_value_varr.LAST;
    p_key_value_varr(i) := p_key;
    p_key_value_varr.EXTEND();
    i := p_key_value_varr.LAST;
    p_key_value_varr(i) := p_value;
  --  x_oper_succeeded := 'Y';
    return l_value;
    EXCEPTION
      WHEN NULL_POINTER_EXCEPTION THEN
        RAISE NULL_POINTER_EXCEPTION;
      WHEN OTHERS THEN
      return l_value;
-- end ;
END Put;

FUNCTION	 GetKeys(
     p_key_value_varr  IN cct_keyvalue_varr
 ) return cct_key_varr IS

   l_key varchar2(4000);
   l_value varchar2(4000) := '';
   l_key_varr cct_key_varr := cct_key_varr();
   i BINARY_INTEGER;
   j BINARY_INTEGER;
 begin
    i := p_key_value_varr.FIRST;
    while (i <= p_key_value_varr.LAST) LOOP
	--dbms_output.put_line (' Value of varray is ' || p_key_value_varr(i));
    l_key := p_key_value_varr(i);
    l_key_varr.EXTEND();
    j := l_key_varr.LAST();
    l_key_varr(j) := l_key;
    i := p_key_value_varr.NEXT(i);
    i := p_key_value_varr.NEXT(i);
    END LOOP;
    return l_key_varr;
    EXCEPTION
      WHEN OTHERS THEN
      return l_key_varr;
-- end ;
END GetKeys;

FUNCTION	 NumOfKeys(
     p_key_value_varr  IN cct_keyvalue_varr
 ) return NUMBER IS

   l_size NUMBER;
   i BINARY_INTEGER;
 begin
    i := p_key_value_varr.COUNT;
    l_size := i/2;
    return l_size;
    EXCEPTION
      WHEN OTHERS THEN
      return l_size;
-- end ;
END NUMOfKeys;



-- Returns key value pairs in the following format:
-- key1:value1;key2:value2;key3:value3;.......;keyn:valuen;
FUNCTION CCT_KeyValue_Varr_ToString
(
    p_key_value_varr  IN cct_keyvalue_varr
)


return VARCHAR2 IS

x_keyvalue_str VARCHAR2(32767) := '';
l_key VARCHAR2(256);
l_value VARCHAR2(256);
i BINARY_INTEGER;
BEGIN
    i := p_key_value_varr.FIRST;
    WHILE i IS NOT NULL LOOP
        l_key := p_key_value_varr(i);
        i := p_key_value_varr.NEXT(i);
        l_value := p_key_value_varr(i);
        x_keyvalue_str := x_keyvalue_str || l_key || ':' || l_value || ';' ;
        i := p_key_value_varr.NEXT(i);
       --dbms_output.put_line(x_keyvalue_str);
    END LOOP;
   --dbms_output.put_line('Returning ' || x_keyvalue_str);
    return x_keyvalue_str;
EXCEPTION
    WHEN OTHERS THEN
       --dbms_output.put_line('CCT_COLLECTIONS_PUB.ToString');
       --dbms_output.put_line(SQLCODE ||SUBSTR(SQLERRM, 1, 100));
        return x_keyvalue_str;
END CCT_KeyValue_Varr_ToString;


END CCT_COLLECTION_UTIL_PUB;


/
