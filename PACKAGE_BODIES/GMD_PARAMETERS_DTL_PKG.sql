--------------------------------------------------------
--  DDL for Package Body GMD_PARAMETERS_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_PARAMETERS_DTL_PKG" AS
/* $Header: GMDPRMDB.pls 120.6 2006/05/24 12:56:25 rkrishan noship $ */


 /*======================================================================
 --  PROCEDURE :
 --   INSERT_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure is used to insert rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */
PROCEDURE INSERT_ROW (
  X_ROWID               OUT NOCOPY VARCHAR2,
  X_PARAMETER_LINE_ID   IN NUMBER,
  X_PARAMETER_ID        IN NUMBER,
  X_PARM_TYPE           IN NUMBER,
  X_PARAMETER_NAME      IN VARCHAR2,
  X_PARAMETER_VALUE     IN VARCHAR2,
  X_CREATION_DATE       IN DATE,
  X_CREATED_BY          IN NUMBER,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
) IS

CURSOR C IS
SELECT ROWID
FROM GMD_PARAMETERS_DTL
WHERE PARAMETER_LINE_ID = X_PARAMETER_LINE_ID;
BEGIN

  INSERT INTO GMD_PARAMETERS_DTL (
    PARAMETER_ID,
    PARAMETER_LINE_ID,
    PARAMETER_TYPE,
    PARAMETER_NAME,
    PARAMETER_VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    X_PARAMETER_ID,
    X_PARAMETER_LINE_ID,
    X_PARM_TYPE,
    X_PARAMETER_NAME,
    X_PARAMETER_VALUE,
    SYSDATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );


  OPEN C;
  FETCH C INTO X_ROWID;
  IF (C%NOTFOUND) THEN
    CLOSE C;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE C;

EXCEPTION WHEN OTHERS THEN
NULL;
END INSERT_ROW;

 /*======================================================================
 --  PROCEDURE :
 --   LOCK_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure is used to lock rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE LOCK_ROW (
  X_PARAMETER_LINE_ID   IN NUMBER,
  X_PARAMETER_ID        IN NUMBER,
  X_PARM_TYPE           IN NUMBER,
  X_PARAMETER_NAME      IN VARCHAR2,
  X_PARAMETER_VALUE     IN VARCHAR2,
  X_LOOKUP_TYPE         IN VARCHAR2
) IS

CURSOR C IS
    SELECT
      PARAMETER_ID,
      PARAMETER_TYPE,
      PARAMETER_NAME,
      PARAMETER_VALUE
    FROM GMD_PARAMETERS_DTL
    WHERE PARAMETER_LINE_ID = X_PARAMETER_LINE_ID
    FOR UPDATE OF PARAMETER_LINE_ID NOWAIT;

CURSOR cur_gem_lookups IS
    SELECT 1
    from GEM_LOOKUPS
    where lookup_code =X_PARAMETER_NAME
    and   lookup_type =X_LOOKUP_TYPE;

  RECINFO C%ROWTYPE;
  GEMINFO Cur_gem_lookups%ROWTYPE;
  NEW_DATA_ENTRY EXCEPTION;
BEGIN
  OPEN C;
  FETCH C INTO RECINFO;



   IF (C%NOTFOUND) THEN
    CLOSE C;
    OPEN cur_gem_lookups;
    FETCH cur_gem_lookups INTO GEMINFO;
    if cur_gem_lookups%NOTFOUND THEN
      CLOSE cur_gem_lookups;
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      APP_EXCEPTION.RAISE_EXCEPTION;
    ELSE
      NULL;
      RAISE NEW_DATA_ENTRY;
    END IF;
  END IF;
  IF c%ISOPEN THEN
   CLOSE C;
  END IF;
  IF cur_gem_lookups%ISOPEN THEN
   Close cur_gem_lookups;
  END IF;
  IF (    (RECINFO.PARAMETER_ID = X_PARAMETER_ID)
      AND ((RECINFO.PARAMETER_TYPE = X_PARM_TYPE)
           OR ((RECINFO.PARAMETER_TYPE IS NULL) AND (X_PARM_TYPE IS NULL)))
      AND ((RECINFO.PARAMETER_NAME = X_PARAMETER_NAME)
           OR ((RECINFO.PARAMETER_NAME IS NULL) AND (X_PARAMETER_NAME IS NULL)))
      AND ((RECINFO.PARAMETER_VALUE = X_PARAMETER_VALUE)
           OR ((RECINFO.PARAMETER_VALUE IS NULL) AND (X_PARAMETER_VALUE IS NULL)))

     )
   THEN
    NULL;

  ELSE
    FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;

  RETURN;
EXCEPTION
WHEN NEW_DATA_ENTRY THEN
   IF c%ISOPEN THEN
   CLOSE C;
   END IF;
   IF cur_gem_lookups%ISOPEN THEN
   Close cur_gem_lookups;
   END IF;
WHEN OTHERS THEN
   IF c%ISOPEN THEN
   CLOSE C;
   END IF;
   IF cur_gem_lookups%ISOPEN THEN
   Close cur_gem_lookups;
   END IF;

END LOCK_ROW;


 /*======================================================================
 --  PROCEDURE :
 --   UPDATE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedure is used to update rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE UPDATE_ROW (
  X_PARAMETER_LINE_ID   IN NUMBER,
  X_PARAMETER_ID        IN NUMBER,
  X_PARM_TYPE           IN NUMBER,
  X_PARAMETER_NAME      IN VARCHAR2,
  X_PARAMETER_VALUE     IN VARCHAR2,
  X_LAST_UPDATE_DATE    IN DATE,
  X_LAST_UPDATED_BY     IN NUMBER,
  X_LAST_UPDATE_LOGIN   IN NUMBER
) IS
BEGIN

  UPDATE GMD_PARAMETERS_DTL
  SET
    PARAMETER_ID        = X_PARAMETER_ID,
    PARAMETER_TYPE      = X_PARM_TYPE,
    PARAMETER_NAME      = X_PARAMETER_NAME,
    PARAMETER_VALUE     = X_PARAMETER_VALUE,
    LAST_UPDATE_DATE    = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY     = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN   = X_LAST_UPDATE_LOGIN
  WHERE PARAMETER_LINE_ID = X_PARAMETER_LINE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
EXCEPTION WHEN OTHERS THEN
NULL;

END UPDATE_ROW;

 /*======================================================================
 --  PROCEDURE :
 --   DELETE_ROW
 --
 --  DESCRIPTION:
 --        This particular procedureis used to  delete rows in detail table
 --
 --  HISTORY
 --        Sriram.S  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE DELETE_ROW (
  X_PARAMETER_LINE_ID IN NUMBER
) IS
BEGIN

  DELETE FROM GMD_PARAMETERS_DTL
  WHERE PARAMETER_LINE_ID = X_PARAMETER_LINE_ID;

  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END DELETE_ROW;



/*======================================================================
 --  PROCEDURE :
 --  GET_PARAMETER_LIST
 --
 --  DESCRIPTION:
 --          Fetches the option values and outputs a table.
 --
 --  HISTORY
 --        KSHUKLA  05-NOV-2004  Created
 --===================================================================== */

PROCEDURE GET_PARAMETER_LIST(pOrgn_id     IN  NUMBER,
                             V_block      IN  VARCHAR2,
                             Xparm_table  IN OUT NOCOPY out_parm_table)  IS

CURSOR cur_parameter_dtl(l_type number,l_gem_type varchar2,l_org_id number) is
select  d.parameter_id parameter_id,d.parameter_line_id parameter_line_id
       ,d.parameter_type parameter_type, d.parameter_name parameter_name
       ,d.PARAMETER_VALUE PARAMETER_VALUE,d.creation_date creation_date
       ,d.last_updated_by last_updated_by,d.last_update_date last_update_date
       ,d.last_update_login last_update_login
       ,d.created_by created_by
from gmd_parameters_dtl d, gmd_parameters_hdr h
where d.parameter_id = h.parameter_id
and d.parameter_type = l_type
and ((h.organization_id = l_org_id) or ((l_org_id is NULL) and (h.organization_id IS NULL)))
UNION
select  NULL parameter_id,NULL parameter_line_id,NULL parameter_type,lookup_code parameter_name, NULL PARAMETER_VALUE
       ,NULL creation_date ,NULL last_updated_by,NULL last_updated_date,NULL last_updated_login,NULL created_by
FROM gem_lookups l
WHERE lookup_type = l_gem_type
and ENABLED_FLAG = 'Y'
AND not exists (select 1
               from gmd_parameters_dtl d, gmd_parameters_hdr h
               where d.parameter_id = h.parameter_id
               and d.parameter_type = l_type
               and ((h.organization_id = l_org_id) or ((l_org_id is NULL) and (h.organization_id IS NULL)))
               and d.parameter_name = l.lookup_code)
ORDER BY PARAMETER_NAME;


X_prcs_cnt NUMBER := 0;
l_lookup_type varchar2(32);
l_type number;
TYPE parm_table is table of cur_parameter_dtl%ROWTYPE;
l_parm_table parm_table;
BEGIN
  IF v_block = 'DTL_FORM' THEN
  	l_lookup_type := 'GMD_FORMULA_PARAMETER';
    l_type :=1;
  ELSIF v_block = 'DTL_OPRN' THEN
  	l_lookup_type := 'GMD_OPERATION_PARAMETER';
    l_type :=2;
  ELSIF v_block = 'DTL_ROUT' THEN
  	l_lookup_type := 'GMD_ROUTING_PARAMETER';
    l_type :=3;
  ELSIF v_block = 'DTL_RECP' THEN
  	l_lookup_type := 'GMD_RECIPE_PARAMETER';
    l_type :=4;
  ELSIF v_block = 'DTL_SUB' THEN
  	l_lookup_type := 'GMD_SUBSTITUTION_PARAMETER';
    l_type :=5;
  ELSIF v_block = 'DTL_LAB' THEN
  	l_lookup_type := 'GMD_LAB_PARAMETER';
    l_type :=6;
  END IF;


FOR l_get_prcs IN cur_parameter_dtl(l_type,l_lookup_type,pOrgn_id)
    LOOP
       X_prcs_cnt    := X_prcs_cnt+1;

       Xparm_table(X_prcs_cnt).parameter_id := l_get_prcs.parameter_id;
       Xparm_table(X_prcs_cnt).parameter_line_id:=l_get_prcs.parameter_line_id;
       Xparm_table(X_prcs_cnt).parameter_type:=NVL(l_get_prcs.parameter_type,l_type);
       Xparm_table(X_prcs_cnt).parameter_name:=l_get_prcs.parameter_name;
       Xparm_table(X_prcs_cnt).parameter_value :=l_get_prcs.parameter_value;
       Xparm_table(X_prcs_cnt).creation_date :=l_get_prcs.creation_date;
       Xparm_table(X_prcs_cnt).last_updated_by:=l_get_prcs.last_updated_by;
       Xparm_table(X_prcs_cnt).created_by:=l_get_prcs.created_by;
    END LOOP;
END GET_PARAMETER_LIST;

END GMD_PARAMETERS_DTL_PKG;


/
