--------------------------------------------------------
--  DDL for Package Body HZ_GNR_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GNR_GEN_PKG" AS
/*$Header: ARHGNRGB.pls 120.32.12010000.2 2009/02/19 09:49:55 amstephe ship $ */
  --------------------------------------
  -- declaration of private global varibles
  --------------------------------------
  G_MAP_REC          HZ_GNR_UTIL_PKG.MAP_REC_TYPE;
  G_MAP_DTLS_TBL     HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;
  G_USAGE_TBL        HZ_GNR_UTIL_PKG.USAGE_TBL_TYPE;
  G_USAGE_DTLS_TBL   HZ_GNR_UTIL_PKG.USAGE_DTLS_TBL_TYPE;
  g_pkgName          VARCHAR2(30);

  g_indent CONSTANT VARCHAR2(2) := '  ';
  -- Hari 2 Lines
  g_country_geo_id  number;
  g_type  varchar2(1); -- need to be removed
  --------------------------------------
  -- forward referencing of private procedures
  FUNCTION useCode (
	   p_geo_element IN VARCHAR2
	) RETURN boolean;

  PROCEDURE genSpec(
    x_status OUT NOCOPY  VARCHAR2);

  PROCEDURE genBody(
   x_status OUT NOCOPY  VARCHAR2);

  -- PROCEDURE enable_debug;
  -- PROCEDURE disable_debug;


  PROCEDURE l(
    str IN     VARCHAR2
  );

  PROCEDURE li(
    str IN     VARCHAR2
  );

  PROCEDURE genPkgSpecHdr (
    p_package_name IN     VARCHAR2
  );

  PROCEDURE genPkgSpecTail (
      p_package_name   IN     VARCHAR2
  );

  PROCEDURE procBegin (
    p_procName IN     VARCHAR2
  );

  PROCEDURE procEnd (
    p_procName IN     VARCHAR2
  );

  PROCEDURE funcBegin (
      p_funcName IN     VARCHAR2
  );

  PROCEDURE funcEnd (
      p_funcName IN     VARCHAR2
  );

  PROCEDURE  validateSpec;

  PROCEDURE  validateBody (
   x_status OUT  NOCOPY VARCHAR2);

  --------------------------------------
  -- private procedures
  /**
   * PRIVATE PROCEDURE l, li, ll, lli, fp
   *
   * DESCRIPTION
   *    Utilities to write line or format line.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_package_name               Package name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   */
  --------------------------------------
  -- This would write a line in the buffer.
  -- This would also introduce a new line char at the end of line.
  PROCEDURE l(
    str IN     VARCHAR2
  ) IS
  BEGIN
    HZ_GEN_PLSQL.add_line(str);
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,str);
    -- dbms_output.put_line(str);
  -- Hari 1 Line
  --hk_store_plsql_proc(G_MAP_REC.MAP_ID,str||fnd_global.local_chr(10),G_TYPE);
  END l;
  --------------------------------------
  -- This would write a line preceeded by an indent and line ends with
  -- a new line char.
  PROCEDURE li(
    str IN     VARCHAR2
  ) IS
  BEGIN
    HZ_GEN_PLSQL.add_line(g_indent||str);
    --    dbms_output.put_line(g_indent||str);
    -- FND_FILE.PUT_LINE(FND_FILE.LOG,g_indent||str);
  -- Hari 1 Line
  --hk_store_plsql_proc(G_MAP_REC.MAP_ID,g_indent||str||fnd_global.local_chr(10),G_TYPE);

  END li;
  --------------------------------------
  -- this would write the line in the buffer without the new line char at eol.
  PROCEDURE ll(
    str IN     VARCHAR2
  ) IS
  BEGIN
      HZ_GEN_PLSQL.add_line(str, false);
      -- FND_FILE.PUT(FND_FILE.LOG,str);
      --  dbms_output.put_line(str);
  -- Hari 1 Line
  --hk_store_plsql_proc(G_MAP_REC.MAP_ID,str,G_TYPE);
  END ll;
  --------------------------------------
  -- this would write a line by preceeding with an indent and no new line char
  -- at the end.
  PROCEDURE lli(
    str IN     VARCHAR2
  ) IS
  BEGIN
      HZ_GEN_PLSQL.add_line(g_indent||str, false);
      -- FND_FILE.PUT(FND_FILE.LOG,g_indent||str);
      --  dbms_output.put_line(g_indent||str);
  -- Hari 1 Line
  --hk_store_plsql_proc(G_MAP_REC.MAP_ID,g_indent||str,G_TYPE);
  END lli;
  --------------------------------------
  FUNCTION fp(
    p_parameter  IN     VARCHAR2
  ) RETURN VARCHAR2 IS
  BEGIN
    RETURN RPAD(p_parameter,35);
  END fp;
    --------------------------------------
  /**
   * PRIVATE function useCode
   *
   * DESCRIPTION
   *     This function is used to inform if the GEO_ELEMENT_CODE
   *     column can be used in the where clause for any given
   *     geo element.
   *     This is needed as currently only geo elements 1 through 5 have
   *     code columns in the geography data model. This function
   *     need not be used once the ER#2907223.
   *     After that this function call will be unnecessary.
   *
   * ARGUMENTS
   *   IN:
   *     p_geo_element geo element column that must be parsed
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   */
  --------------------------------------
  FUNCTION useCode (
	   p_geo_element IN VARCHAR2
	) RETURN boolean is
  BEGIN
	IF (SUBSTR(p_geo_element, 18, 2) IN ('1','2','3','4','5')) THEN
                -- dbms_output.put_line('using the code');
		RETURN TRUE;
	ELSE
                -- dbms_output.put_line('not using the code');
		RETURN FALSE;
	END IF;
   END useCode;
  --------------------------------------

  --------------------------------------
  /**
   * PRIVATE PROCEDURE genPkgSpecHdr
   *
   * DESCRIPTION
   *     Generate package header.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_package_name               Package name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   */
  --------------------------------------
  PROCEDURE genPkgSpecHdr (
    p_package_name IN     VARCHAR2
  ) IS
  BEGIN
    -- new a package body object
    HZ_GEN_PLSQL.new(p_package_name, 'PACKAGE');
    l('CREATE OR REPLACE PACKAGE '||p_package_name||' AS');
    l('');
    l('/*=======================================================================+');
    l(' |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|');
    l(' |                          All rights reserved.                         |');
    l(' +=======================================================================+');
    l(' | NAME '||p_package_name);
    l(' |');
    l(' | DESCRIPTION');
    l(' |   This package body is generated by TCA for geoName referencing. ');
    l(' |');
    l(' | HISTORY');
    l(' |  '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')||'      Generated.');
    l(' |');
    l(' *=======================================================================*/');
    l('');
  END genPkgSpecHdr;
 --------------------------------------
  /**
   * PRIVATE PROCEDURE genPkgBdyHdr
   *
   * DESCRIPTION
   *     Generate package Body header.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_package_name               Package name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   */
  --------------------------------------
  PROCEDURE genPkgBdyHdr (
    p_package_name IN     VARCHAR2
  ) IS
  BEGIN
  -- new a package body object
    HZ_GEN_PLSQL.new(p_package_name, 'PACKAGE BODY');
    l('CREATE OR REPLACE PACKAGE BODY '||p_package_name||' AS');
    l('');
    l('/*=======================================================================+');
    l(' |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|');
    l(' |                          All rights reserved.                         |');
    l(' +=======================================================================+');
    l(' | NAME '||p_package_name);
    l(' |');
    l(' | DESCRIPTION');
    l(' |   This package body is generated by TCA for geoName referencing. ');
    l(' |');
    l(' | HISTORY');
    l(' |  '||TO_CHAR(SYSDATE,'MM/DD/YYYY HH:MI:SS')||'      Generated.');
    l(' |');
    l(' *=======================================================================*/');
    l(' ');
  END genPkgBdyHdr;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE genPkgSpecTail
   *
   * DESCRIPTION
   *     Generate package tail.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_package_name               Package name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE genPkgSpecTail (
      p_package_name   IN     VARCHAR2
  ) IS
  BEGIN
    l('END '||p_package_name||';');
    -- compile the package.
    HZ_GEN_PLSQL.compile_code;
  END genPkgSpecTail;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE populate_mdu_tbl
   *
   * DESCRIPTION
   *     This populates a table of records of map_loc_rec for a usage.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_usage_id               usage_id
   *   OUT:
   *     x_mdu_tbl                Table of records of map_loc_rec type
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE populate_mdu_tbl(p_usage_id in number,x_mdu_tbl OUT NOCOPY HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE) IS
    i number := 0;
    FUNCTION exists_mapping(p_usage_id in number,p_geography_type in varchar2) return boolean IS
      j NUMBER;
    BEGIN
      j:= 0;
      IF G_USAGE_DTLS_TBL.COUNT > 0 THEN
        j := G_USAGE_DTLS_TBL.FIRST;
        LOOP
          IF G_USAGE_DTLS_TBL(j).USAGE_ID = p_usage_id AND G_USAGE_DTLS_TBL(j).GEOGRAPHY_TYPE = p_geography_type THEN
            RETURN TRUE;
          END IF;
          EXIT WHEN j = G_USAGE_DTLS_TBL.LAST;
          j := G_USAGE_DTLS_TBL.NEXT(j);
        END LOOP;
      END IF;
      RETURN FALSE;
    END exists_mapping;
  BEGIN
    i := 0;
    IF G_MAP_DTLS_TBL.COUNT > 0 THEN
      i := G_MAP_DTLS_TBL.FIRST;
      LOOP
        IF exists_mapping(P_USAGE_ID,G_MAP_DTLS_TBL(i).GEOGRAPHY_TYPE) THEN
          X_MDU_TBL(i).LOC_SEQ_NUM       := G_MAP_DTLS_TBL(i).LOC_SEQ_NUM;
          X_MDU_TBL(i).LOC_COMPONENT     := G_MAP_DTLS_TBL(i).LOC_COMPONENT;
          X_MDU_TBL(i).GEOGRAPHY_TYPE    := G_MAP_DTLS_TBL(i).GEOGRAPHY_TYPE;
          X_MDU_TBL(i).GEO_ELEMENT_COL   := G_MAP_DTLS_TBL(i).GEO_ELEMENT_COL;
        END IF;
        EXIT WHEN i = G_MAP_DTLS_TBL.LAST;
        i := G_MAP_DTLS_TBL.NEXT(i);
      END LOOP;
    END IF;

  END populate_mdu_tbl;

  --------------------------------------
  /**
   * PRIVATE PROCEDURE genPkgBdyInit
   *
   * DESCRIPTION
   *     Generate package Initialization section.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_map_id               Map_id
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE genPkgBdyInit (
   x_status OUT  NOCOPY VARCHAR2) IS

    i NUMBER := 0;
    j NUMBER := 0;
    l_mdu_tbl HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;


  BEGIN
    -- initializing the retun value
    x_status := FND_API.G_RET_STS_SUCCESS;

    l(' ');
    l('BEGIN ');

    SELECT GEOGRAPHY_ID
    INTO   g_country_geo_id
    FROM   HZ_GEOGRAPHIES
    WHERE  COUNTRY_CODE = G_MAP_REC.COUNTRY_CODE
    AND    GEOGRAPHY_TYPE = 'COUNTRY';

    l('  G_COUNTRY_GEO_ID                    := '||g_country_geo_id||';');
    l('  G_MAP_REC.MAP_ID                    := '||G_MAP_REC.MAP_ID||';');
    l('  G_MAP_REC.COUNTRY_CODE              := '''||G_MAP_REC.COUNTRY_CODE||''';');
    l('  G_MAP_REC.LOC_TBL_NAME              := '''||G_MAP_REC.LOC_TBL_NAME||''';');
    l('  G_MAP_REC.ADDRESS_STYLE             := '''||NVL(G_MAP_REC.ADDRESS_STYLE,'NULL')||''';');
    l(' ');

    IF G_MAP_DTLS_TBL.COUNT > 0 THEN
      i := G_MAP_DTLS_TBL.FIRST;
      LOOP -- Populate the global variable for all the mapped columns.
        l('  G_MAP_DTLS_TBL('||i||').LOC_SEQ_NUM       := '||G_MAP_DTLS_TBL(i).LOC_SEQ_NUM||';');
        l('  G_MAP_DTLS_TBL('||i||').LOC_COMPONENT     := '''||G_MAP_DTLS_TBL(i).LOC_COMPONENT||''';');
        l('  G_MAP_DTLS_TBL('||i||').GEOGRAPHY_TYPE    := '''||G_MAP_DTLS_TBL(i).GEOGRAPHY_TYPE||''';');
        l('  G_MAP_DTLS_TBL('||i||').GEO_ELEMENT_COL   := '''||G_MAP_DTLS_TBL(i).GEO_ELEMENT_COL||''';');
        IF G_MAP_DTLS_TBL(i).GEOGRAPHY_TYPE = 'COUNTRY' THEN
          l('  G_MAP_DTLS_TBL('||i||').GEOGRAPHY_ID    := '||g_country_geo_id||';');
        END IF;
        EXIT WHEN i = G_MAP_DTLS_TBL.LAST;
        i := G_MAP_DTLS_TBL.NEXT(i);
      END LOOP;
    END IF;

    i := 0;
    IF G_USAGE_TBL.COUNT > 0 THEN
      i := G_USAGE_TBL.FIRST;
      LOOP -- Populate the global variable for all the Usagees
        l(' ');
        l('  G_USAGE_TBL('||i||').USAGE_ID             := '||G_USAGE_TBL(i).USAGE_ID||';');
        l('  G_USAGE_TBL('||i||').MAP_ID               := '||G_USAGE_TBL(i).MAP_ID||';');
        l('  G_USAGE_TBL('||i||').USAGE_CODE           := '''||G_USAGE_TBL(i).USAGE_CODE||''';');

        IF G_USAGE_DTLS_TBL.COUNT > 0 THEN
          j := G_USAGE_DTLS_TBL.FIRST;
          LOOP -- Populate the global variable for all the Usages and Details
            IF G_USAGE_TBL(i).USAGE_ID = G_USAGE_DTLS_TBL(j).USAGE_ID THEN
              l('  G_USAGE_DTLS_TBL('||j||').USAGE_ID        := '||G_USAGE_DTLS_TBL(j).USAGE_ID||';');
              l('  G_USAGE_DTLS_TBL('||j||').GEOGRAPHY_TYPE  := '''||G_USAGE_DTLS_TBL(j).GEOGRAPHY_TYPE||''';');
            END IF;
            EXIT WHEN j = G_USAGE_DTLS_TBL.LAST;
            j := G_USAGE_DTLS_TBL.NEXT(j);
          END LOOP;
        END IF;

        -- Populate the G_MDU_TBL||Usage_id table
        populate_mdu_tbl(G_USAGE_TBL(i).USAGE_ID, l_mdu_tbl);
        j := 0;
        IF L_MDU_TBL.COUNT > 0 THEN
          j := L_MDU_TBL.FIRST;
          LOOP
            l('  G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID||'('||j||').LOC_SEQ_NUM       := '||L_MDU_TBL(j).LOC_SEQ_NUM||';');
            l('  G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID||'('||j||').LOC_COMPONENT     := '''||L_MDU_TBL(j).LOC_COMPONENT||''';');
            l('  G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID||'('||j||').GEOGRAPHY_TYPE    := '''||L_MDU_TBL(j).GEOGRAPHY_TYPE||''';');
            l('  G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID||'('||j||').GEO_ELEMENT_COL   := '''||L_MDU_TBL(j).GEO_ELEMENT_COL||''';');

            IF L_MDU_TBL(j).GEOGRAPHY_TYPE = 'COUNTRY' THEN
              l('  G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID||'('||j||').GEOGRAPHY_ID      := '||g_country_geo_id||';');
            END IF;

            EXIT WHEN j = L_MDU_TBL.LAST;
            j := L_MDU_TBL.NEXT(j);
          END LOOP;
        END IF;

        EXIT WHEN i = G_USAGE_TBL.LAST;
        i := G_USAGE_TBL.NEXT(i);
      END LOOP;
    END IF;

    l(' ');

  END genPkgBdyInit;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE genPkgBdyTail
   *
   * DESCRIPTION
   *     Generate package tail.
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_package_name               Package name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE genPkgBdyTail (
      p_package_name   IN     VARCHAR2
  ) IS
  BEGIN
    l('END '||p_package_name||';');
    -- compile the package.
    HZ_GEN_PLSQL.compile_code;
  END genPkgBdyTail;
   --------------------------------------
  /**
   * PRIVATE PROCEDURE procBegin
   *
   * DESCRIPTION
   *     Generate procedure hdr
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_procName  procedure name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE funcBegin (
      p_funcName IN     VARCHAR2
  ) IS
  BEGIN
-- Hari    li('--------------------------------------');
-- Hari    li('/**');
-- Hari    li(' * FUNCTION '||p_funcName);
-- Hari    li(' *');
-- Hari    li(' * DESCRIPTION');
-- Hari    li(' *     This is a private function ');
-- Hari    li(' *');
-- Hari    li(' */');
-- Hari    l(' ');
    li('FUNCTION '||p_funcName||'(');
  END funcBegin;
    --------------------------------------
  /**
   * PRIVATE PROCEDURE funcEnd
   *
   * DESCRIPTION
   *     Generate function tail
   *
   *
   * ARGUMENTS
   *   IN:
   *     p_funcName  function name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE funcEnd (
    p_funcName IN     VARCHAR2
  ) IS
  BEGIN
    l(' ');
    li('END '||p_funcName||';');
  END funcEnd;
  --------------------------------------

   --------------------------------------
  /**
   * PRIVATE PROCEDURE procBegin
   *
   * DESCRIPTION
   *     Generate procedure hdr
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_procName  procedure name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE procBegin (
      p_procName IN     VARCHAR2
  ) IS
  BEGIN
-- Hari    li('--------------------------------------');
-- Hari    li('/**');
-- Hari    li(' * PROCEDURE '||p_procName);
-- Hari    li(' *');
-- Hari    li(' * DESCRIPTION');
-- Hari    li(' *     This map specific private procedure is used to identify the');
-- Hari    li(' *     geography ids ');
-- Hari    li(' *');
-- Hari    li(' * ARGUMENTS');
-- Hari    li(' *');
-- Hari    li(' *   IN OUT:');
-- Hari    li(' *   x_mapTbl   Table of records that has location sequence number,');
-- Hari    li(' *              geo element, type and loc components and their values');
-- Hari    li(' *   OUT:');
-- Hari    li(' *   x_status   indicates if the srchGeo was sucessfull or not.');
-- Hari    li(' *');
-- Hari    li(' */');
-- Hari    l(' ');
    li('PROCEDURE '||p_procName||'(');
  END procBegin;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE procEnd
   *
   * DESCRIPTION
   *     Generate procedure tail
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *     p_procName  procedure name.
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE procEnd (
    p_procName IN     VARCHAR2
  ) IS
  BEGIN
    l(' ');
    li('END '||p_procName||';');
  END procEnd;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE    get_usage_API_Body
   *
   * DESCRIPTION
   *     to generate Body for get_usage_API function
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE  get_usage_API_Body IS
    l_funcName varchar2(30);

  BEGIN
    -- name the function
    l_funcName := 'get_usage_API';
    -- write the header comments, function name
    funcBegin(l_funcName);
    -- write parameters
    li('  P_USAGE_CODE               VARCHAR2) RETURN VARCHAR2 IS');
    -- write function body
    l('  i number;');
    l('  l_API_Name varchar2(30);');
    l(' ');
    l('   BEGIN');
    l('     i := 0;');
    l('     IF G_USAGE_TBL.COUNT > 0 THEN');
    l('       i := G_USAGE_TBL.FIRST;');
    l('       LOOP');
    l('         IF G_USAGE_TBL(i).USAGE_CODE = P_USAGE_CODE THEN');
    l('           IF G_USAGE_TBL(i).USAGE_CODE = ''GEOGRAPHY'' THEN');
    l('             l_API_Name := ''validateGeo'';');
    l('           ELSIF G_USAGE_TBL(i).USAGE_CODE = ''TAX'' THEN');
    l('             l_API_Name := ''validateTax'';');
    l('           ELSE');
    l('             l_API_Name := ''validate''||G_USAGE_TBL(i).USAGE_ID;');
    l('           END IF;');
    l('         END IF;');
    l('         EXIT WHEN i = G_USAGE_TBL.LAST;');
    l('         i := G_USAGE_TBL.NEXT(i);');
    l('       END LOOP;');
    l('     END IF;');
    l(' ');
    l('     RETURN l_API_Name;');
    funcEnd(l_funcName);
    l(' ');
  END get_usage_API_Body;
  --------------------------------------
  --------------------------------------
  /**
   * PRIVATE PROCEDURE    get_usage_API_Spec
   *
   * DESCRIPTION
   *     to generate spec for get_usage_API function
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE  get_usage_API_spec IS
    l_funcName varchar2(30);

  BEGIN
    -- name the function
    l_funcName := 'get_usage_API';
    -- write the header comments, function name
    funcBegin(l_funcName);
    -- write parameters
    li('  P_USAGE_CODE               VARCHAR2) RETURN VARCHAR2;');
    l(' ');
  END get_usage_API_Spec;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE    validateHrSpec
   *
   * DESCRIPTION
   *     to generate spec for validateSpec procedure
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE  validateHrSpec IS
    l_procName varchar2(30);
    i number;
  BEGIN
    l_procName := 'validateHrLoc';
    procBegin(l_procName);

    -- write the parameters
    li('  P_LOCATION_ID               IN NUMBER,');
    li('  X_STATUS                    OUT NOCOPY VARCHAR2);');
    l(' ');

  END validateHrSpec;

  --------------------------------------
  /**
   * PRIVATE PROCEDURE    validateSpec
   *
   * DESCRIPTION
   *     to generate spec for validateSpec procedure
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE  validateSpec IS
    l_procName varchar2(30);
    i number;
  BEGIN
    i := 0;
    IF G_USAGE_TBL.COUNT > 0 THEN
      i := G_USAGE_TBL.FIRST;
      LOOP
        -- name the procedure
        IF G_USAGE_TBL(i).USAGE_CODE = 'GEOGRAPHY' THEN
          l_procName := 'validateGeo';
        ELSIF G_USAGE_TBL(i).USAGE_CODE = 'TAX' THEN
          l_procName := 'validateTax';
        ELSE
          l_procName := 'validate'||G_USAGE_TBL(i).USAGE_ID;
        END IF;

        -- write the header comments, procedure name
        procBegin(l_procName);

        -- write the parameters
        li('  P_LOCATION_ID               IN NUMBER,');
        li('  P_COUNTRY                   IN VARCHAR2,');
        li('  P_STATE                     IN VARCHAR2,');
        li('  P_PROVINCE                  IN VARCHAR2,');
        li('  P_COUNTY                    IN VARCHAR2,');
        li('  P_CITY                      IN VARCHAR2,');
        li('  P_POSTAL_CODE               IN VARCHAR2,');
        li('  P_POSTAL_PLUS4_CODE         IN VARCHAR2,');
        li('  P_ATTRIBUTE1                IN VARCHAR2,');
        li('  P_ATTRIBUTE2                IN VARCHAR2,');
        li('  P_ATTRIBUTE3                IN VARCHAR2,');
        li('  P_ATTRIBUTE4                IN VARCHAR2,');
        li('  P_ATTRIBUTE5                IN VARCHAR2,');
        li('  P_ATTRIBUTE6                IN VARCHAR2,');
        li('  P_ATTRIBUTE7                IN VARCHAR2,');
        li('  P_ATTRIBUTE8                IN VARCHAR2,');
        li('  P_ATTRIBUTE9                IN VARCHAR2,');
        li('  P_ATTRIBUTE10               IN VARCHAR2,');
        li('  P_LOCK_FLAG                 IN VARCHAR2 DEFAULT FND_API.G_TRUE,');
        li('  X_CALL_MAP                  IN OUT NOCOPY VARCHAR2,');
        li('  P_CALLED_FROM               IN VARCHAR2,');
        li('  P_ADDR_VAL_LEVEL            IN VARCHAR2,');
        li('  X_ADDR_WARN_MSG             OUT NOCOPY VARCHAR2,');
        li('  X_ADDR_VAL_STATUS           OUT NOCOPY VARCHAR2,');
        li('  X_STATUS                    OUT NOCOPY VARCHAR2);');
        l(' ');

        EXIT WHEN i = G_USAGE_TBL.LAST;
        i := G_USAGE_TBL.NEXT(i);
      END LOOP;
    END IF;

  END validateSpec;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE    validateHrBody
   *
   * DESCRIPTION
   *     to generate body for srchGeo procedure
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE  validateHrBody (
   x_status OUT NOCOPY  VARCHAR2) IS

    -- local variable declaration
    l_procName      varchar2(30);
    l_mdu_tbl       HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;
    l_usage_id      number;
    l_open_cur      varchar2(2000);
    l_fetch_cur     varchar2(2000);
    l_mdu_tbl_name  varchar2(30);
    i number;
    j number;

  BEGIN
    x_status := FND_API.g_ret_sts_success;
    i := 0;
    IF G_USAGE_TBL.COUNT > 0 THEN
      i := G_USAGE_TBL.FIRST;
      LOOP
        IF G_USAGE_TBL(i).USAGE_CODE = 'TAX' THEN
          l_usage_id      := G_USAGE_TBL(i).USAGE_ID;
          l_mdu_tbl_name  := 'G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID;
        END IF;
      EXIT WHEN i = G_USAGE_TBL.LAST;
      i := G_USAGE_TBL.NEXT(i);
      END LOOP;
    END IF;
    populate_mdu_tbl(l_usage_id, l_mdu_tbl);
    l(' ');
    -- write the header comments, procedure name
    l_procName := 'validateHrLoc';
    procBegin(l_procName);
    li('  P_LOCATION_ID               IN NUMBER,');
    li('  X_STATUS                    OUT NOCOPY VARCHAR2) IS');
    l(' ');
    li('  TYPE getGeo IS REF CURSOR;');
    li('  c_getGeo                getGeo;');
    li('  c_getGeo1               getGeo;');
    l(' ');
    li('  l_multiple_parent_flag  VARCHAR2(1);');
    li('  l_sql                   VARCHAR2(9000);');
    li('  l_status                VARCHAR2(1);');
    li('  l_geography_type        VARCHAR2(30);');
    li('  l_geography_id          NUMBER;');
    li('  L_MDU_TBL               HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
    li('  LL_MDU_TBL              HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
    li('  l_loc_components_rec    HZ_GNR_UTIL_PKG.LOC_COMPONENTS_REC_TYPE; -- not actually required here');
    l(' ');
    l('   l_module_prefix CONSTANT VARCHAR2(30) := ''HZ:ARHGNRGB:'||g_pkgName||''';');
    l('   l_module        CONSTANT VARCHAR2(30) := ''ADDRESS_VALIDATION'';');
    l('   l_debug_prefix           VARCHAR2(30) := p_location_id;');
    l(' ');
    l('   l_temp_postal_code       VARCHAR2(360);');
    i := 0;
    IF L_MDU_TBL.COUNT > 0 THEN
      i := L_MDU_TBL.FIRST;
      LOOP
        li('  l_value'||i||'              VARCHAR2(360);');
        li('  l_type'||i||'               VARCHAR2(30);');

        EXIT WHEN i = L_MDU_TBL.LAST;
        i := L_MDU_TBL.NEXT(i);
      END LOOP;
    END IF;

    l(' ');
    li('BEGIN ');
    li('  -- defaulting the sucess status');
    l('    x_status := FND_API.g_ret_sts_success;');
    l('    L_MDU_TBL            := '||l_mdu_tbl_name||';');
    l('    LL_MDU_TBL           := '||l_mdu_tbl_name||';');
    l('    --hk_debugl(''Validate HR Loc Start for the location_id :''||p_location_id);');
    l('    --hk_debugl(''The MDU table structure'');');
    l('    --hk_debugt(L_MDU_TBL);');
    l(' ');
    l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('      hz_utility_v2pub.debug ');
    l('           (p_message      => ''Begin of validation for validateHrLoc.'',');
    l('            p_prefix        => l_debug_prefix,');
    l('            p_msg_level     => fnd_log.level_procedure,');
    l('            p_module_prefix => l_module_prefix,');
    l('            p_module        => l_module');
    l('           );');
    l('    END IF; ');
    l(' ');
    l('    IF L_MDU_TBL.COUNT = 1 THEN');
    l(' ');
    l('      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('        hz_utility_v2pub.debug ');
    l('             (p_message      => '' This means country is the only required mapped column for validation. Call create_gnr with map status S'',');
    l('              p_prefix        => l_debug_prefix,');
    l('              p_msg_level     => fnd_log.level_statement,');
    l('              p_module_prefix => l_module_prefix,');
    l('              p_module        => l_module');
    l('             );');
    l('      END IF; ');
    l(' ');
    l('      -- This means country is the only required mapped column for validation.');
    l('      -- and country is already populated in the L_MDU_TBL in the initialization section of this package.');
    l('      --hk_debugt(L_MDU_TBL); ----- Code to display the output.');
    l('      --hk_debugl(''Calling create_gnr With Map_status "S"'');');
    l('      IF P_LOCATION_ID IS NOT NULL THEN');
    l('          HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
    l('                                     ''TAX'',''S'',l_loc_components_rec,''T'',L_MDU_TBL,l_status);');
    l('      END IF;');
    l('      x_status := FND_API.g_ret_sts_success;');
    l('      RETURN;');
    l('    END IF;');
    l('    --hk_debugl(''L_MDU_TBL has count count more than 1'');');
    l(' ');

    i := 0;
    IF L_MDU_TBL.COUNT > 0 THEN
      i := L_MDU_TBL.FIRST;
      l('    BEGIN ');
      l('      SELECT '||L_MDU_TBL(i).LOC_COMPONENT);
      LOOP
        EXIT WHEN i = L_MDU_TBL.LAST;
        i := L_MDU_TBL.NEXT(i);
        l('             ,'||L_MDU_TBL(i).LOC_COMPONENT);
      END LOOP;
      i := L_MDU_TBL.FIRST;
      l('      INTO    L_MDU_TBL('||i||').LOC_COMPVAL');
      LOOP
        EXIT WHEN i = L_MDU_TBL.LAST;
        i := L_MDU_TBL.NEXT(i);
        l('             ,L_MDU_TBL('||i||').LOC_COMPVAL');
      END LOOP;

      l('      FROM   HR_LOCATIONS_ALL ');
      l('    WHERE LOCATION_ID = P_LOCATION_ID;');
      l(' ');
      l('    EXCEPTION WHEN OTHERS THEN  ');
      l('      x_status := FND_API.g_ret_sts_error;');
      l('    END; ');
    END IF;
    l('    --hk_debugl(''The MDU table after location components populated`'');');
    l('    --hk_debugt(L_MDU_TBL);');

    l_open_cur := NULL;
    l_fetch_cur:= NULL;

    j := 0;
    IF L_MDU_TBL.COUNT > 0 THEN
      j := L_MDU_TBL.FIRST;
      LOOP
        IF j>1 THEN
          l('    l_value'||j||' := NVL(L_MDU_TBL('||j||').LOC_COMPVAL,''X'') ;');
          l('    IF l_value'||j||' = ''X'' THEN');
          l('      l_type'||j||' := ''X'';');
          l('    ELSE');
          l('      l_type'||j||' := L_MDU_TBL('||j||').GEOGRAPHY_TYPE;');
          l('      -- store the geography_type of the lowest address component that has a value passed in');
          l('      l_geography_type := l_type'||j||';');
          l(' ');
          l('      -- Fix for Bug 7240974 (Nishant) (ZIP+4 functionality) ');
          l('      -- check if component is POSTAL_CODE, change from ZIP+4 format to ZIP for US based on setup');
          l('      IF L_MDU_TBL('||j||').LOC_COMPONENT = ''POSTAL_CODE'' THEN ');
          l('         l_temp_postal_code := HZ_GNR_UTIL_PKG.postal_code_to_validate(P_COUNTRY_CODE => L_MDU_TBL(1).LOC_COMPVAL,');
          l('                                                                       P_POSTAL_CODE  => L_MDU_TBL('||j||').LOC_COMPVAL); ');
          l('         L_MDU_TBL('||j||').LOC_COMPVAL := l_temp_postal_code; ');
          l('         l_value'||j||' := l_temp_postal_code; ');
          l('      END IF ;');
          l(' ');
          l('    END IF;');
          l(' ');
          l_open_cur := l_open_cur||',l_type'||j||',l_value'||j;
          l_fetch_cur := l_fetch_cur||',LL_MDU_TBL('||j||').GEOGRAPHY_ID';
        END IF;

        EXIT WHEN j = L_MDU_TBL.LAST;
        j := L_MDU_TBL.NEXT(j);
      END LOOP;
    END IF;
    l(' ');
    l_open_cur := l_open_cur||',l_geography_type;';
    l_fetch_cur := l_fetch_cur||';';
    l('     LL_MDU_TBL       := L_MDU_TBL;');
    l('     l_sql := HZ_GNR_UTIL_PKG.getQuery(L_MDU_TBL,L_MDU_TBL,x_status);');
    l('     --hk_debugl(''The SQL query'');');
    l('     --hk_debugl(l_sql);');
    l(' ');
    l('     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('       hz_utility_v2pub.debug ');
    l('            (p_message      => '' The SQL query : ''||l_sql,');
    l('             p_prefix        => l_debug_prefix,');
    l('             p_msg_level     => fnd_log.level_statement,');
    l('             p_module_prefix => l_module_prefix,');
    l('             p_module        => l_module');
    l('            );');
    l('     END IF; ');
    l(' ');
-- BEGIN NS
    l('     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('       hz_utility_v2pub.debug ');
    l('            (p_message      => '' The BIND values are : ''||G_MAP_REC.COUNTRY_CODE||'':''||g_country_geo_id ');
    l('           '||replace(replace(l_open_cur,',','||'':''||'),';',','));
    l('             p_prefix        => l_debug_prefix,');
    l('             p_msg_level     => fnd_log.level_statement,');
    l('             p_module_prefix => l_module_prefix,');
    l('             p_module        => l_module');
    l('            );');
    l('     END IF; ');
    l(' ');
-- END NS
    l('     OPEN  c_getGeo FOR l_sql USING G_MAP_REC.COUNTRY_CODE,g_country_geo_id');
    l('           '||l_open_cur);
    l('     FETCH c_getGeo INTO l_geography_id,l_multiple_parent_flag,LL_MDU_TBL(1).GEOGRAPHY_ID');
    l('           '||l_fetch_cur);
    l('     IF c_getGeo%NOTFOUND THEN ');
    l('       --hk_debugl(''No Match found for the usage level search'');');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' No Match found for the usage level search '',');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('       HZ_GNR_UTIL_PKG.fix_no_match(LL_MDU_TBL,x_status);');
    l('       x_status := FND_API.G_RET_STS_ERROR;');
    l('     ELSE ');
    l('       --Fetching once more to see where there are multiple records');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' Fetching once more to see where there are multiple records '',');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('       FETCH c_getGeo INTO l_geography_id,l_multiple_parent_flag,LL_MDU_TBL(1).GEOGRAPHY_ID');
    l('           '||l_fetch_cur);
    l('       IF c_getGeo%FOUND THEN -- not able to identify a unique record');
    l('         --hk_debugl(''Multiple Match found for the usage level search'');');


    l('         -- Get the query again with identifier type as NAME if multiple match found');
    l('         -- If it returns a record, we are able to derive a unique record for identifier type as NAME');
    l('         l_sql := HZ_GNR_UTIL_PKG.getQueryforMultiMatch(L_MDU_TBL,L_MDU_TBL,x_status);');
    l('         OPEN  c_getGeo1 FOR l_sql USING G_MAP_REC.COUNTRY_CODE,g_country_geo_id');
    l('               '||l_open_cur);
    l(' ');
    l('         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('           hz_utility_v2pub.debug ');
    l('                (p_message      => ''Before the fetch of the query with identifier type as NAME after multiple match found'',');
    l('                 p_prefix        => l_debug_prefix,');
    l('                 p_msg_level     => fnd_log.level_statement,');
    l('                 p_module_prefix => l_module_prefix,');
    l('                 p_module        => l_module');
    l('                );');
    l('         END IF; ');
    l(' ');
    l('     --hk_debugt(LL_MDU_TBL);');
    l('         FETCH c_getGeo1 INTO l_geography_id,l_multiple_parent_flag,LL_MDU_TBL(1).GEOGRAPHY_ID');
    l('               '||l_fetch_cur);
    l('         IF c_getGeo1%FOUND THEN  ');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message       => ''Able to found a unique record or a record with multiple parent flag = Y with identifier type as NAME'',');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('         ELSE -- Not able to found a unique record with identifier type as NAME');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => '' Not able to find a record with with identifier type as NAME. '',');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('           LL_MDU_TBL       := L_MDU_TBL;');
    l('           x_status := FND_API.G_RET_STS_ERROR;');
    l('         END IF; ');
    l('         CLOSE c_getGeo1;');
    l(' ');


    l('       ELSE -- a unique record or a record with multiple parent flag = Y is found');
    l('         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('           hz_utility_v2pub.debug ');
    l('                (p_message      => '' A unique record or a record with multiple parent flag = Y is found '',');
    l('                 p_prefix        => l_debug_prefix,');
    l('                 p_msg_level     => fnd_log.level_statement,');
    l('                 p_module_prefix => l_module_prefix,');
    l('                 p_module        => l_module');
    l('                );');
    l('         END IF; ');
    l('       END IF;');
    l(' ');
    l('       IF l_multiple_parent_flag = ''Y'' AND x_status <> FND_API.G_RET_STS_ERROR THEN');
    l('         --hk_debugl(''Multiple Parent Match found for the usage level search'');');
    l('         IF HZ_GNR_UTIL_PKG.fix_multiparent(l_geography_id,LL_MDU_TBL) = TRUE THEN');
    l('           --hk_debugl(''Sucessfully Fixed the Multiple Parent Case '');');
    l('           NULL;');
    l('         ELSE --  Multiple parent case not able to find a unique record ');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => '' Multiple parent case not able to find a unique record'',');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('           --hk_debugl(''Unable to Fix the Multiple Parent Case '');');
    l('           x_status := FND_API.G_RET_STS_ERROR;');
    l('         END IF;');
    l('       ELSE -- a unique record is found');
    l('         --hk_debugl(''Successfully found a unique record '');');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => '' A unique record is found '',');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('       END IF;');
    l('     END IF;');
    l('     CLOSE c_getGeo;');
    l(' ');
    l('     IF x_status =  FND_API.G_RET_STS_SUCCESS THEN ');
    l('       --Following call will try to derive missing lower level compoents  ');
    l('       --hk_debugl(''LL_MDU Table before Fix_child '');');
    l('       --hk_debugt(LL_MDU_TBL);');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' Calling fix_child. This call will try to derive missing lower level compoents.'',');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('       IF HZ_GNR_UTIL_PKG.fix_child(LL_MDU_TBL) = FALSE THEN');
    l('         --hk_debugl(''LL_MDU Table after Fix_child '');');
    l('         --hk_debugt(LL_MDU_TBL);');
    l('         x_status := HZ_GNR_UTIL_PKG.get_usage_val_status(LL_MDU_TBL,L_MDU_TBL);');
    l('         --hk_debugl(''LL_MDU Table after HZ_GNR_UTIL_PKG.get_usage_val_status '');');
    l('         --hk_debugt(LL_MDU_TBL);');
    l('       END IF;');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' Return status after fix_child ''||x_status,');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('     END IF;');
    l(' ');
    l('     HZ_GNR_UTIL_PKG.fill_values(LL_MDU_TBL);');
    l('     --hk_debugl(''LL_MDU Table after HZ_GNR_UTIL_PKG.fill_values '');');
    l('     --hk_debugt(LL_MDU_TBL);');
    l(' ');
    l('    IF x_status = FND_API.g_ret_sts_success THEN');
    l(' ');
    l('              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('                hz_utility_v2pub.debug ');
    l('                     (p_message      => '' Calling create_gnr with map status S.'',');
    l('                      p_prefix        => l_debug_prefix,');
    l('                      p_msg_level     => fnd_log.level_statement,');
    l('                      p_module_prefix => l_module_prefix,');
    l('                      p_module        => l_module');
    l('                     );');
    l('              END IF; ');
    l(' ');
    l('      HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
    l('                                   ''TAX'',''S'',l_loc_components_rec,''T'',LL_MDU_TBL,l_status);');
    l('    ELSE ');
    l(' ');
    l('              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('                hz_utility_v2pub.debug ');
    l('                     (p_message      => '' Calling create_gnr with map status E.'',');
    l('                      p_prefix        => l_debug_prefix,');
    l('                      p_msg_level     => fnd_log.level_statement,');
    l('                      p_module_prefix => l_module_prefix,');
    l('                      p_module        => l_module');
    l('                     );');
    l('              END IF; ');
    l(' ');
    l('      HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
    l('                                     ''TAX'',''E'',l_loc_components_rec,''T'',LL_MDU_TBL,l_status);');
    l('    END IF;');
    l(' ');
    l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('      hz_utility_v2pub.debug ');
    l('           (p_message      => ''End of validation for validateHrLoc.'',');
    l('            p_prefix        => l_debug_prefix,');
    l('            p_msg_level     => fnd_log.level_procedure,');
    l('            p_module_prefix => l_module_prefix,');
    l('            p_module        => l_module');
    l('           );');
    l('    END IF; ');
    l(' ');
    l('            --hk_debugt(LL_MDU_TBL); ----- Code to display the output.');
    ---- end procedure
    procEnd(l_procName);
  END validateHrBody;
  --------------------------------------
  /**
   * PRIVATE PROCEDURE    validateBody
   *
   * DESCRIPTION
   *     to generate body for srchGeo procedure
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * NOTES
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
  PROCEDURE  validateBody (
   x_status OUT NOCOPY  VARCHAR2) IS

    -- local variable declaration
    l_procName      varchar2(30);
    i               number;
    j               number;
    l_mdu_tbl       HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;
    l_open_cur      varchar2(2000);
    l_fetch_cur     varchar2(2000);
    l_usage_id      number;
    l_usage_code    varchar2(30);
    l_mdu_tbl_name  varchar2(30);

  BEGIN
    x_status := FND_API.g_ret_sts_success;
    l(' ');
    -- write the header comments, procedure name
    l_procName := 'validateForMap';
    procBegin(l_procName);
    li('  p_loc_components_rec        IN HZ_GNR_UTIL_PKG.LOC_COMPONENTS_REC_TYPE,');
    li('  x_map_dtls_tbl              IN OUT NOCOPY HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE,');
    li('  X_CAUSE                     OUT NOCOPY VARCHAR2,');
    li('  X_STATUS                    OUT NOCOPY VARCHAR2) IS');
    l(' ');
    l(' ');
    li('  TYPE getGeo IS REF CURSOR;');
    li('  c_getGeo                getGeo;');
    li('  c_getGeo1               getGeo;');
    l(' ');
    li('  l_multiple_parent_flag  VARCHAR2(1);');
    li('  l_sql                   VARCHAR2(9000);');
    li('  l_status                VARCHAR2(1);');
    li('  l_geography_type        VARCHAR2(30);');
    li('  l_geography_id          NUMBER;');
    li('  L_MAP_DTLS_TBL          HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
    l(' ');
    l('    l_module_prefix CONSTANT VARCHAR2(30) := ''HZ:ARHGNRGB:'||g_pkgName||''';');
    l('    l_module        CONSTANT VARCHAR2(30) := ''ADDRESS_VALIDATION'';');
    l('    l_debug_prefix           VARCHAR2(30);');
    l(' ');

    j := 0;
    IF G_MAP_DTLS_TBL.COUNT > 0 THEN
      j := G_MAP_DTLS_TBL.FIRST;
      LOOP
        li('  l_value'||j||'              VARCHAR2(360);');
        li('  l_type'||j||'               VARCHAR2(30);');

        EXIT WHEN j = G_MAP_DTLS_TBL.LAST;
        j := G_MAP_DTLS_TBL.NEXT(j);
      END LOOP;
    END IF;
    l(' ');
    -- procedure body
    li('BEGIN ');
    l(' ');
    l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('      hz_utility_v2pub.debug ');
    l('           (p_message      => ''Begin of Validate for Map'',');
    l('            p_prefix        => l_debug_prefix,');
    l('            p_msg_level     => fnd_log.level_procedure,');
    l('            p_module_prefix => l_module_prefix,');
    l('            p_module        => l_module');
    l('           );');
    l('    END IF; ');
    l(' ');
    l('    --hk_debugl(''Validate for Map Start'');');
    li('  -- defaulting the sucess status');
    li('  x_status := FND_API.g_ret_sts_success;');
    l(' ');
    l('    L_MAP_DTLS_TBL       := X_MAP_DTLS_TBL;');
    l('    --hk_debugl(''The Map table passed in with loc comp values'');');
    l('    --hk_debugt(L_MAP_DTLS_TBL);');
    l(' ');
    l('    IF L_MAP_DTLS_TBL.COUNT = 1 THEN');
    l('      -- This means country is the only required mapped column for validation.');
    l('      -- and country is already populated in the L_MAP_DTLS_TBL in the initialization section of this package.');
    l('      x_status := FND_API.g_ret_sts_success;');
    l('      RETURN;');
    l('    END IF;');
    l(' ');
    l('    IF HZ_GNR_UTIL_PKG.getLocCompCount(L_MAP_DTLS_TBL) = 0 THEN');
    l('      --hk_debugl(''HZ_GNR_UTIL_PKG.getLocCompCount = 0'');');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' HZ_GNR_UTIL_PKG.getLocCompCount = 0 '',');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('      --No other location component value other than country is passed. ');
    l('      --Following call will try to derive missing lower level compoents  ');
    l('      IF HZ_GNR_UTIL_PKG.fix_child(L_MAP_DTLS_TBL) = FALSE THEN');
    l('        x_cause  := ''MISSING_CHILD'';');
    l(' ');
    l('             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('               hz_utility_v2pub.debug ');
    l('                    (p_message      => '' x_cause : ''||x_cause,');
    l('                     p_prefix        => l_debug_prefix,');
    l('                     p_msg_level     => fnd_log.level_statement,');
    l('                     p_module_prefix => l_module_prefix,');
    l('                     p_module        => l_module');
    l('                    );');
    l('             END IF; ');
    l(' ');
--    l('        HZ_GNR_UTIL_PKG.fill_values(L_MAP_DTLS_TBL);');
    l('        x_status := FND_API.G_RET_STS_ERROR;');
    l('        X_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
    l('        RETURN;');
    l('      ELSE');
    l(' ');
    l('             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('               hz_utility_v2pub.debug ');
    l('                    (p_message      => '' Derived the missing lower level compoents '',');
    l('                     p_prefix        => l_debug_prefix,');
    l('                     p_msg_level     => fnd_log.level_statement,');
    l('                     p_module_prefix => l_module_prefix,');
    l('                     p_module        => l_module');
    l('                    );');
    l('             END IF; ');
    l(' ');
--    l('        HZ_GNR_UTIL_PKG.fill_values(L_MAP_DTLS_TBL);');
    l('        x_status := FND_API.G_RET_STS_SUCCESS;');
    l('        X_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
    l('        RETURN;');
    l('      END IF;');
    l('    END IF;');
    l(' ');
    l_open_cur := NULL;
    l_fetch_cur:= NULL;

    j := 0;
    IF G_MAP_DTLS_TBL.COUNT > 0 THEN
      j := G_MAP_DTLS_TBL.FIRST;
      LOOP
        IF j>1 THEN
          l('    l_value'||j||' := NVL(L_MAP_DTLS_TBL('||j||').LOC_COMPVAL,''X'') ;');
          l('    IF l_value'||j||' = ''X'' THEN');
          l('      l_type'||j||' := ''X'';');
          l('    ELSE');
          l('      l_type'||j||' := L_MAP_DTLS_TBL('||j||').GEOGRAPHY_TYPE;');
          l('      -- store the geography_type of the lowest address component that has a value passed in');
          l('      l_geography_type := l_type'||j||';');
          l('    END IF;');
          l(' ');
          l_open_cur := l_open_cur||',l_type'||j||',l_value'||j;
          l_fetch_cur := l_fetch_cur||',L_MAP_DTLS_TBL('||j||').GEOGRAPHY_ID';
        END IF;

        EXIT WHEN j = G_MAP_DTLS_TBL.LAST;
        j := G_MAP_DTLS_TBL.NEXT(j);
      END LOOP;
    END IF;
    l(' ');
    l_open_cur := l_open_cur||',l_geography_type;';
    l_fetch_cur := l_fetch_cur||';';

    l('     l_sql := HZ_GNR_UTIL_PKG.getQuery(L_MAP_DTLS_TBL,L_MAP_DTLS_TBL,x_status);');
    l('    --hk_debugl(''The SQL query'');');
    l('    --hk_debugl(l_sql);');
    l(' ');
    l('     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('       hz_utility_v2pub.debug ');
    l('            (p_message      => '' The SQL query : ''||l_sql,');
    l('             p_prefix        => l_debug_prefix,');
    l('             p_msg_level     => fnd_log.level_statement,');
    l('             p_module_prefix => l_module_prefix,');
    l('             p_module        => l_module');
    l('            );');
    l('     END IF; ');
    l(' ');
    l('     OPEN  c_getGeo FOR l_sql USING G_MAP_REC.COUNTRY_CODE,g_country_geo_id');
    l('           '||l_open_cur);
    l('     --hk_debugl(''Before the first fetch'');');
    l(' ');
    l('     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('       hz_utility_v2pub.debug ');
    l('            (p_message      => '' Before the first fetch'',');
    l('             p_prefix        => l_debug_prefix,');
    l('             p_msg_level     => fnd_log.level_statement,');
    l('             p_module_prefix => l_module_prefix,');
    l('             p_module        => l_module');
    l('            );');
    l('     END IF; ');
    l(' ');
    l('     --hk_debugt(L_MAP_DTLS_TBL);');
    l('     FETCH c_getGeo INTO l_geography_id,l_multiple_parent_flag,L_MAP_DTLS_TBL(1).GEOGRAPHY_ID');
    l('           '||l_fetch_cur);
    l('     IF c_getGeo%NOTFOUND THEN  ');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' NOT FOUND of the first fetch'',');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('       --hk_debugl(''NOT FOUND of the first fetch'');');
    l('       --hk_debugt(L_MAP_DTLS_TBL);');
    l('       x_cause  := ''NO_MATCH'';');
    l('       HZ_GNR_UTIL_PKG.fix_no_match(L_MAP_DTLS_TBL,x_status);');
    l('       --hk_debugl(''Map_loc table after Fix'');');
    l('       --hk_debugt(L_MAP_DTLS_TBL);');
    l('       x_status := FND_API.G_RET_STS_ERROR;');
    l('     ELSE ');
    l('       --Fetching once more to see where there are multiple records');
    l(' ');
    l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('         hz_utility_v2pub.debug ');
    l('              (p_message      => '' Fetching once more to see where there are multiple records '',');
    l('               p_prefix        => l_debug_prefix,');
    l('               p_msg_level     => fnd_log.level_statement,');
    l('               p_module_prefix => l_module_prefix,');
    l('               p_module        => l_module');
    l('              );');
    l('       END IF; ');
    l(' ');
    l('       FETCH c_getGeo INTO l_geography_id,l_multiple_parent_flag,L_MAP_DTLS_TBL(1).GEOGRAPHY_ID');
    l('           '||l_fetch_cur);
    l('       IF c_getGeo%FOUND THEN -- not able to identify a unique record');
    l(' ');
    l('         -- Get the query again with identifier type as NAME if multiple match found');
    l('         -- If it returns a record, we are able to derive a unique record for identifier type as NAME');
    l('         l_sql := HZ_GNR_UTIL_PKG.getQueryforMultiMatch(L_MAP_DTLS_TBL,L_MAP_DTLS_TBL,x_status);');
    l('         OPEN  c_getGeo1 FOR l_sql USING G_MAP_REC.COUNTRY_CODE,g_country_geo_id');
    l('               '||l_open_cur);
    l(' ');
    l('         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('           hz_utility_v2pub.debug ');
    l('                (p_message      => ''Before the fetch of the query with identifier type as NAME after multiple match found'',');
    l('                 p_prefix        => l_debug_prefix,');
    l('                 p_msg_level     => fnd_log.level_statement,');
    l('                 p_module_prefix => l_module_prefix,');
    l('                 p_module        => l_module');
    l('                );');
    l('         END IF; ');
    l(' ');
    l('         --hk_debugt(L_MAP_DTLS_TBL);');
    l('         FETCH c_getGeo1 INTO l_geography_id,l_multiple_parent_flag,L_MAP_DTLS_TBL(1).GEOGRAPHY_ID');
    l('               '||l_fetch_cur);
    l('         IF c_getGeo1%FOUND THEN  ');
------
    l('           -- check if there is another row with same STANDARD_NAME, in that case it is error case ');
    l('           FETCH c_getGeo1 INTO l_geography_id,l_multiple_parent_flag,L_MAP_DTLS_TBL(1).GEOGRAPHY_ID ');
    l('                '||l_fetch_cur);
    l('           IF c_getGeo1%NOTFOUND THEN  -- success (only 1 rec with same primary name exists)' );
    l(' ');
    l('             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('                hz_utility_v2pub.debug ');
    l('                    (p_message       => ''MAP-Able to found a unique record or a record with multiple parent flag = Y with identifier type as NAME'',');
    l('                     p_prefix        => l_debug_prefix,');
    l('                     p_msg_level     => fnd_log.level_statement,');
    l('                     p_module_prefix => l_module_prefix,');
    l('                     p_module        => l_module');
    l('                    );');
    l('             END IF; ');
    l(' ');
    l('           ELSE -- Not able to find a unique record with identifier type as NAME ');
    l(' ');
    l('               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('	                 hz_utility_v2pub.debug ');
    l('	                      (p_message      => ''MAP-Not able to find a record with with identifier type as NAME. ''|| ');
    l('	                                         '' More than 1 rec exists with same STANDARD NAME'', ');
    l('	                       p_prefix        => l_debug_prefix, ');
    l('	                       p_msg_level     => fnd_log.level_statement, ');
    l('	                       p_module_prefix => l_module_prefix, ');
    l('	                       p_module        => l_module ');
    l('	                      ); ');
    l('	               END IF; ');
    l(' ');
    l('	               x_cause  := ''MULTIPLE_MATCH''; ');
    l('	               x_status := FND_API.G_RET_STS_ERROR; ');
    l('	               RETURN; ');
    l('	          END IF; ');
    l(' ');
-------
    l('         ELSE -- Not able to found a unique record with identifier type as NAME');
    l('           x_cause  := ''MULTIPLE_MATCH'';');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => '' Not able to find a record with with identifier type as NAME. x_cause : ''||x_cause,');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('           x_status := FND_API.G_RET_STS_ERROR;');
    l('           RETURN;');
    l('         END IF; ');
    l('       CLOSE c_getGeo1;');
    l(' ');
    l('       ELSE -- a unique record or a record with multiple parent flag = Y is found');
    l(' ');
    l('         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('           hz_utility_v2pub.debug ');
    l('                (p_message       => '' A unique record or a record with multiple parent flag = Y is found '',');
    l('                 p_prefix        => l_debug_prefix,');
    l('                 p_msg_level     => fnd_log.level_statement,');
    l('                 p_module_prefix => l_module_prefix,');
    l('                 p_module        => l_module');
    l('                );');
    l('         END IF; ');
    l(' ');
    l('       END IF;');
    l(' ');
    l('       IF l_multiple_parent_flag = ''Y'' THEN');
    l('         IF HZ_GNR_UTIL_PKG.fix_multiparent(l_geography_id,L_MAP_DTLS_TBL) = TRUE THEN');
    l('           NULL; -- a unique record is found');
    l('         ELSE --  Multiple parent case not able to find a unique record ');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => '' Multiple parent case not able to find a unique record'',');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('           x_cause  := ''MULTIPLE_PARENT'';');
    l('           X_MAP_DTLS_TBL := L_MAP_DTLS_TBL;');
    l('           x_status := FND_API.G_RET_STS_ERROR;');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => '' x_cause : ''||x_cause,');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('           RETURN;');
    l('         END IF;');
    l(' ');
    l('       ELSE -- a unique record is found');
    l(' ');
    l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('             hz_utility_v2pub.debug ');
    l('                  (p_message      => ''A unique record is found '',');
    l('                   p_prefix        => l_debug_prefix,');
    l('                   p_msg_level     => fnd_log.level_statement,');
    l('                   p_module_prefix => l_module_prefix,');
    l('                   p_module        => l_module');
    l('                  );');
    l('           END IF; ');
    l(' ');
    l('       END IF;');
    l(' ');
    l('     END IF;');
    l(' ');
    l('     CLOSE c_getGeo;');
    l(' ');
    l(' ');
    l('     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('       hz_utility_v2pub.debug ');
    l('            (p_message      => '' Calling fix_child. This call will try to derive missing lower level compoents.'',');
    l('             p_prefix        => l_debug_prefix,');
    l('             p_msg_level     => fnd_log.level_statement,');
    l('             p_module_prefix => l_module_prefix,');
    l('             p_module        => l_module');
    l('            );');
    l('     END IF; ');
    l(' ');
    l('     --Following call will try to derive missing lower level compoents  ');
    l('     IF HZ_GNR_UTIL_PKG.fix_child(L_MAP_DTLS_TBL) = FALSE THEN');
    l('       x_cause  := ''MISSING_CHILD'';');
    l(' ');
    l('             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('               hz_utility_v2pub.debug ');
    l('                    (p_message      => '' x_cause : ''||x_cause,');
    l('                     p_prefix        => l_debug_prefix,');
    l('                     p_msg_level     => fnd_log.level_statement,');
    l('                     p_module_prefix => l_module_prefix,');
    l('                     p_module        => l_module');
    l('                    );');
    l('             END IF; ');
    l(' ');
--    l('       HZ_GNR_UTIL_PKG.fill_values(L_MAP_DTLS_TBL);');
    l('       x_status             := FND_API.G_RET_STS_ERROR;');
    l('       X_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
    l('       RETURN;');
    l('     END IF;');
--    l('     HZ_GNR_UTIL_PKG.fill_values(L_MAP_DTLS_TBL);');
    l(' ');
    l('     X_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
    l(' ');
    l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
    l('      hz_utility_v2pub.debug ');
    l('           (p_message      => ''End of Validate for Map'',');
    l('            p_prefix        => l_debug_prefix,');
    l('            p_msg_level     => fnd_log.level_procedure,');
    l('            p_module_prefix => l_module_prefix,');
    l('            p_module        => l_module');
    l('           );');
    l('    END IF; ');
    l(' ');
    ---- end procedure
    procEnd(l_procName);

    i := 0;
    IF G_USAGE_TBL.COUNT > 0 THEN
      i := G_USAGE_TBL.FIRST;
      LOOP
        l_usage_id      := G_USAGE_TBL(i).USAGE_ID;
        l_usage_code    := G_USAGE_TBL(i).USAGE_CODE;
        l_mdu_tbl_name  := 'G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID;
        -- name the procedure
        IF G_USAGE_TBL(i).USAGE_CODE = 'GEOGRAPHY' THEN
          l_procName := 'validateGeo';
        ELSIF G_USAGE_TBL(i).USAGE_CODE = 'TAX' THEN
          l_procName := 'validateTax';
        ELSE
          l_procName := 'validate'||G_USAGE_TBL(i).USAGE_ID;
        END IF;

        l(' ');
        -- write the header comments, procedure name
        procBegin(l_procName);

        -- write the parameters
        li('  P_LOCATION_ID               IN NUMBER,');
        li('  P_COUNTRY                   IN VARCHAR2,');
        li('  P_STATE                     IN VARCHAR2,');
        li('  P_PROVINCE                  IN VARCHAR2,');
        li('  P_COUNTY                    IN VARCHAR2,');
        li('  P_CITY                      IN VARCHAR2,');
        li('  P_POSTAL_CODE               IN VARCHAR2,');
        li('  P_POSTAL_PLUS4_CODE         IN VARCHAR2,');
        li('  P_ATTRIBUTE1                IN VARCHAR2,');
        li('  P_ATTRIBUTE2                IN VARCHAR2,');
        li('  P_ATTRIBUTE3                IN VARCHAR2,');
        li('  P_ATTRIBUTE4                IN VARCHAR2,');
        li('  P_ATTRIBUTE5                IN VARCHAR2,');
        li('  P_ATTRIBUTE6                IN VARCHAR2,');
        li('  P_ATTRIBUTE7                IN VARCHAR2,');
        li('  P_ATTRIBUTE8                IN VARCHAR2,');
        li('  P_ATTRIBUTE9                IN VARCHAR2,');
        li('  P_ATTRIBUTE10               IN VARCHAR2,');
        li('  P_LOCK_FLAG                 IN VARCHAR2,');
        li('  X_CALL_MAP                  IN OUT NOCOPY VARCHAR2,');
        li('  P_CALLED_FROM               IN VARCHAR2,');
        li('  P_ADDR_VAL_LEVEL            IN VARCHAR2,');
        li('  X_ADDR_WARN_MSG             OUT NOCOPY VARCHAR2,');
        li('  X_ADDR_VAL_STATUS           OUT NOCOPY VARCHAR2,');
        li('  X_STATUS                    OUT NOCOPY VARCHAR2) IS');
        l(' ');

        -- cursor or local variable declaration
        li('  l_loc_components_rec HZ_GNR_UTIL_PKG.LOC_COMPONENTS_REC_TYPE;');
        l(' ');
        li('  TYPE getGeo IS REF CURSOR;');
        li('  c_getGeo                getGeo;');
        li('  c_getGeo1               getGeo;');
        l(' ');
        li('  l_multiple_parent_flag  VARCHAR2(1);');
        li('  l_sql                   VARCHAR2(9000);');
        li('  l_cause                 VARCHAR2(30);');
        li('  l_usage_code            VARCHAR2(30);');
        li('  l_usage_id              NUMBER;');
        li('  l_status                VARCHAR2(1);');
        li('  l_get_addr_val          VARCHAR2(1);');
        li('  l_geography_type        VARCHAR2(30);');
        li('  l_geography_id          NUMBER;');
        li('  L_MDU_TBL               HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
        li('  LL_MAP_DTLS_TBL         HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
        li('  L_MAP_DTLS_TBL          HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
        l(' ');
        l('    l_module_prefix CONSTANT VARCHAR2(30) := ''HZ:ARHGNRGB:'||g_pkgName||''';');
        l('    l_module        CONSTANT VARCHAR2(30) := ''ADDRESS_VALIDATION'';');
        l('    l_debug_prefix           VARCHAR2(30) := p_location_id;');
        l(' ');

        populate_mdu_tbl(G_USAGE_TBL(i).USAGE_ID, l_mdu_tbl);
        j := 0;
        IF L_MDU_TBL.COUNT > 0 THEN
          j := L_MDU_TBL.FIRST;
          LOOP
            li('  l_value'||j||'              VARCHAR2(360);');
            li('  l_type'||j||'               VARCHAR2(30);');

            EXIT WHEN j = L_MDU_TBL.LAST;
            j := L_MDU_TBL.NEXT(j);
          END LOOP;
        END IF;
        l(' ');

        -- procedure body
        li('BEGIN ');
        l(' ');
        li('  -- defaulting the sucess status');
        li('  x_status := FND_API.g_ret_sts_success;');
        l('   --hk_debugl(''Processing Location record with location_id :- ''||nvl(to_char(p_location_id),''NULL_LOCATION_ID''));');
        li('  l_loc_components_rec.COUNTRY                 := P_COUNTRY;');
        li('  l_loc_components_rec.STATE                   := P_STATE;');
        li('  l_loc_components_rec.PROVINCE                := P_PROVINCE;');
        li('  l_loc_components_rec.COUNTY                  := P_COUNTY;');
        li('  l_loc_components_rec.CITY                    := P_CITY;');
        li('  l_loc_components_rec.POSTAL_CODE             := HZ_GNR_UTIL_PKG.postal_code_to_validate(P_COUNTRY,P_POSTAL_CODE);');
        li('  l_loc_components_rec.POSTAL_PLUS4_CODE       := P_POSTAL_PLUS4_CODE;');
        li('  l_loc_components_rec.ATTRIBUTE1              := P_ATTRIBUTE1;');
        li('  l_loc_components_rec.ATTRIBUTE2              := P_ATTRIBUTE2;');
        li('  l_loc_components_rec.ATTRIBUTE3              := P_ATTRIBUTE3;');
        li('  l_loc_components_rec.ATTRIBUTE4              := P_ATTRIBUTE4;');
        li('  l_loc_components_rec.ATTRIBUTE5              := P_ATTRIBUTE5;');
        li('  l_loc_components_rec.ATTRIBUTE6              := P_ATTRIBUTE6;');
        li('  l_loc_components_rec.ATTRIBUTE7              := P_ATTRIBUTE7;');
        li('  l_loc_components_rec.ATTRIBUTE8              := P_ATTRIBUTE8;');
        li('  l_loc_components_rec.ATTRIBUTE9              := P_ATTRIBUTE9;');
        li('  l_loc_components_rec.ATTRIBUTE10             := P_ATTRIBUTE10;');

        l(' ');
	l('    L_USAGE_ID           := '||l_usage_id||';');
        l('    L_USAGE_CODE         := '''||l_usage_code||''';');
        l('    L_MDU_TBL            := '||l_mdu_tbl_name||';');
        l('    L_MAP_DTLS_TBL       := G_MAP_DTLS_TBL;');
        l('    l_get_addr_val       := ''N'';');
        l(' ');
        l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('      hz_utility_v2pub.debug ');
        l('           (p_message       => ''Begin of validation for ''||L_USAGE_CODE,');
        l('            p_prefix        => l_debug_prefix,');
        l('            p_msg_level     => fnd_log.level_procedure,');
        l('            p_module_prefix => l_module_prefix,');
        l('            p_module        => l_module');
        l('           );');
        l('    END IF; ');
        l(' ');
        l('    IF P_LOCATION_ID IS NOT NULL AND P_CALLED_FROM <> ''GNR'' THEN');
        l('      --hk_debugl(''Before check_GNR_For_Usage'');');
        l('      IF HZ_GNR_UTIL_PKG.check_GNR_For_Usage(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                             L_USAGE_CODE,L_MDU_TBL,x_status) = TRUE THEN');
        l('        --hk_debugl(''After check_GNR_For_Usage  with status :- ''||x_status);');
        l(' ');
        l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('      hz_utility_v2pub.debug ');
        l('           (p_message      => ''There is already a procedded success record in GNR log table.'',');
        l('            p_prefix        => l_debug_prefix,');
        l('            p_msg_level     => fnd_log.level_statement,');
        l('            p_module_prefix => l_module_prefix,');
        l('            p_module        => l_module');
        l('           );');
        l('    END IF; ');
        l(' ');
        l('        x_status := FND_API.g_ret_sts_success;');
        l('        X_ADDR_VAL_STATUS := x_status;');
        l('        RETURN;');
        l('      END IF;');
        l('    END IF;');
        l(' ');
        l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('      hz_utility_v2pub.debug ');
        l('           (p_message      => ''Not able to find an existing success record in GNR log table.'',');
        l('            p_prefix        => l_debug_prefix,');
        l('            p_msg_level     => fnd_log.level_statement,');
        l('            p_module_prefix => l_module_prefix,');
        l('            p_module        => l_module');
        l('           );');
        l('    END IF; ');
        l(' ');
        l('    -- After the following call L_MAP_DTLS_TBL will have the components value populated.');
        l('    HZ_GNR_UTIL_PKG.getLocCompValues(G_MAP_REC.LOC_TBL_NAME,L_LOC_COMPONENTS_REC,L_MAP_DTLS_TBL,x_status);');
        l(' ');
        l('    -- Below code will overwrite the LOC_COMPVAL for COUNTRY to COUNTRY_CODE');
        l('    -- This change is to update COUNTRY column in locations table with COUNTRY_CODE ');
        l('    -- even if the table has Country name in this column and the validation is success ');
        l('    L_MAP_DTLS_TBL(1).LOC_COMPVAL := G_MAP_REC.COUNTRY_CODE;');
        l(' ');
        l('    -- After the following call L_MDU_TBL will have the components value populated.');
        l('    HZ_GNR_UTIL_PKG.getLocCompValues(G_MAP_REC.LOC_TBL_NAME,L_LOC_COMPONENTS_REC,L_MDU_TBL,x_status);');
        l(' ');
        l('    --hk_debugl('' value of X_CALL_MAP : ''||X_CALL_MAP);');
        l('    IF X_CALL_MAP = ''Y'' THEN');
        l('      LL_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
        l(' ');
        l('      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('        hz_utility_v2pub.debug ');
        l('           (p_message      => ''Before calling validate for Map '',');
        l('            p_prefix        => l_debug_prefix,');
        l('            p_msg_level     => fnd_log.level_statement,');
        l('            p_module_prefix => l_module_prefix,');
        l('            p_module        => l_module');
        l('           );');
        l('      END IF; ');
        l(' ');
        l('      validateForMap(L_LOC_COMPONENTS_REC,LL_MAP_DTLS_TBL,l_cause,x_status);');
        l('      --hk_debugl(''Back from Validate for Map  with status :- ''||x_status||''.. and case :''||l_cause);');
        l(' ');
        l('      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('        hz_utility_v2pub.debug ');
        l('           (p_message      => ''Back from Validate for Map with status : .''||x_status||''.. and case :''||l_cause,');
        l('            p_prefix        => l_debug_prefix,');
        l('            p_msg_level     => fnd_log.level_statement,');
        l('            p_module_prefix => l_module_prefix,');
        l('            p_module        => l_module');
        l('           );');
        l('      END IF; ');
        l(' ');
        -- Check added on 19-APR-2006 (Part of fix for bug 5011366 ) by Nishant
        l('      -- This usage level check is required upfront because usage level validation will ignore ');
        l('      -- some of the passed in parameters for the complete mapping and may result in wrong status ');
        l('      IF (x_status = FND_API.g_ret_sts_error) THEN ');
        l(' ');
        l('        -- hk_debugl(''Trying to check if usage level validation is success even with map validation as error..''); ');
        l('        -- hk_debugl(''TABLE that is returned by Validate For Map''); ');
        l('        -- hk_debugt(LL_MAP_DTLS_TBL); ');
        l('        -- hk_debugl(''Usage Map Table With loc comp values''); ');
        l('        -- hk_debugt(L_MDU_TBL); ');
        l(' ');
        l('        IF HZ_GNR_UTIL_PKG.get_usage_val_status(LL_MAP_DTLS_TBL,L_MDU_TBL) = FND_API.G_RET_STS_SUCCESS THEN ');
        l('          -- hk_debugl(''COMPLETE mapping is error but is sufficient for passed usage. So setting X_STATUS to success''); ');
        l('          x_status := FND_API.g_ret_sts_success; ');
        l(' ');
        l('          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('             hz_utility_v2pub.debug ');
        l('                 (p_message      => ''COMPLETE mapping is error but is sufficient for passed usage. So setting X_STATUS to success'',');
        l('                  p_prefix        => l_debug_prefix,');
        l('                  p_msg_level     => fnd_log.level_statement,');
        l('                  p_module_prefix => l_module_prefix,');
        l('                  p_module        => l_module');
        l('                 );');
        l('          END IF; ');
        l(' ');
        l('        END IF; ');
        l('      END IF; ');
        l('      -------End of status check for usage level ----------+ ');
        l(' ');

        -- end of check addition (bug 5011366)
        l('      IF x_status = FND_API.g_ret_sts_success THEN');
        l('        --hk_debugt(LL_MAP_DTLS_TBL); ----- Code to display the output.');
        l('        -- Set the address validation status to success since x_statusis success ');
        l('        X_ADDR_VAL_STATUS := x_status;');
        l('        IF P_LOCATION_ID IS NOT NULL THEN');
        l(' ');
        l('          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('            hz_utility_v2pub.debug ');
        l('                 (p_message      => '' Location id is not null. Call fill_values, create_gnr and Return back.'',');
        l('                  p_prefix        => l_debug_prefix,');
        l('                  p_msg_level     => fnd_log.level_statement,');
        l('                  p_module_prefix => l_module_prefix,');
        l('                  p_module        => l_module');
        l('                 );');
        l('          END IF; ');
        l(' ');
        l('          HZ_GNR_UTIL_PKG.fill_values(LL_MAP_DTLS_TBL);');
        l('          HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                     L_USAGE_CODE,''S'',L_LOC_COMPONENTS_REC,p_lock_flag,LL_MAP_DTLS_TBL,l_status);');
        l('        END IF;');
        l(' ');
        l('        X_CALL_MAP := ''N'';');
        l('        RETURN;');
        l(' ');
        l('      ELSE ');
        l(' ');
        l('        IF P_LOCATION_ID IS NOT NULL THEN');
        l('          --hk_debugl(''Table that is returned by Validate For Map'');');
        l('          --hk_debugt(LL_MAP_DTLS_TBL);');
        l('          --hk_debugl(''Usage Map Table With loc comp values'');');
        l('          --hk_debugt(L_MDU_TBL);');
        l('          IF HZ_GNR_UTIL_PKG.do_usage_val(l_cause,L_MAP_DTLS_TBL,L_MDU_TBL,LL_MAP_DTLS_TBL,l_status) = FALSE THEN');
        l(' ');
        l('            IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('              hz_utility_v2pub.debug ');
        l('                 (p_message      => '' No usage level validation is required. Call create_gnr with the map status'',');
        l('                  p_prefix        => l_debug_prefix,');
        l('                  p_msg_level     => fnd_log.level_statement,');
        l('                  p_module_prefix => l_module_prefix,');
        l('                  p_module        => l_module');
        l('                 );');
        l('            END IF; ');
        l(' ');
        l('            -- This means no usage level validation is required');
        l('            IF HZ_GNR_UTIL_PKG.get_usage_val_status(LL_MAP_DTLS_TBL,L_MDU_TBL) = FND_API.G_RET_STS_ERROR THEN');
        l(' ');
        l('              HZ_GNR_UTIL_PKG.fill_values(LL_MAP_DTLS_TBL);');
        l('              -- This below call is to derive the address validation status and set the message ');
        l('              X_ADDR_VAL_STATUS := HZ_GNR_UTIL_PKG.getAddrValStatus(LL_MAP_DTLS_TBL,L_MDU_TBL,P_CALLED_FROM,P_ADDR_VAL_LEVEL,x_addr_warn_msg,''E'',x_status);');
        l('              --hk_debugl(''Calling create_gnr With Map_status "E"'');');
        l(' ');
        l('              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('                hz_utility_v2pub.debug ');
        l('                     (p_message      => '' Calling create_gnr with map status E.'',');
        l('                      p_prefix        => l_debug_prefix,');
        l('                      p_msg_level     => fnd_log.level_statement,');
        l('                      p_module_prefix => l_module_prefix,');
        l('                      p_module        => l_module');
        l('                     );');
        l('              END IF; ');
        l(' ');
        l('              HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                       L_USAGE_CODE,''E'',L_LOC_COMPONENTS_REC,p_lock_flag,LL_MAP_DTLS_TBL,l_status);');
        l('              --hk_debugl(''Status after create_gnr : ''||l_status);');
        l('            ELSE ');
        l(' ');
        l('              HZ_GNR_UTIL_PKG.fill_values(LL_MAP_DTLS_TBL);');
        l('              -- This below call is to derive the address validation status and set the message ');
        l('              X_ADDR_VAL_STATUS := HZ_GNR_UTIL_PKG.getAddrValStatus(LL_MAP_DTLS_TBL,L_MDU_TBL,P_CALLED_FROM,P_ADDR_VAL_LEVEL,x_addr_warn_msg,''S'',x_status);');
        l('              --hk_debugl(''Calling create_gnr With Map_status "S"'');');
        l(' ');
        l('              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('                hz_utility_v2pub.debug ');
        l('                     (p_message      => '' Calling create_gnr with map status S.'',');
        l('                      p_prefix        => l_debug_prefix,');
        l('                      p_msg_level     => fnd_log.level_statement,');
        l('                      p_module_prefix => l_module_prefix,');
        l('                      p_module        => l_module');
        l('                     );');
        l('              END IF; ');
        l(' ');
        l('              HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                       L_USAGE_CODE,''S'',L_LOC_COMPONENTS_REC,p_lock_flag,LL_MAP_DTLS_TBL,l_status);');
        l('              --hk_debugl(''Status after create_gnr : ''||l_status);');
        l('              x_status := FND_API.g_ret_sts_success;');
        l('            END IF;');
        l(' ');
        l('            X_CALL_MAP := ''N'';');
        l('            RETURN;');
        l(' ');
        l('          ELSE ');
        l('            NULL; -- do_usage_val has concluded that usage level validation has to go through.');
        l('          END IF;');
        l('        END IF;');
        l('      END IF;');
        l(' ');
        l('      l_get_addr_val := ''Y'';');
        l('      X_CALL_MAP := ''N'';');
        l(' ');
        l('    END IF;');
        l(' ');
        l('    IF L_MDU_TBL.COUNT = 1 THEN');
        l(' ');
        l('      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('        hz_utility_v2pub.debug ');
        l('             (p_message      => '' This means country is the only required mapped column for validation. Call create_gnr with map status S'',');
        l('              p_prefix        => l_debug_prefix,');
        l('              p_msg_level     => fnd_log.level_statement,');
        l('              p_module_prefix => l_module_prefix,');
        l('              p_module        => l_module');
        l('             );');
        l('      END IF; ');
        l(' ');
        l('      -- This means country is the only required mapped column for validation.');
        l('      -- and country is already populated in the L_MDU_TBL in the initialization section of this package.');
        l('      --hk_debugt(L_MDU_TBL); ----- Code to display the output.');
        l('      --hk_debugl(''Calling create_gnr With Map_status "S"'');');
        l('      -- This below call is to derive the address validation status and set the message ');
        l('      X_ADDR_VAL_STATUS := HZ_GNR_UTIL_PKG.getAddrValStatus(L_MDU_TBL,L_MDU_TBL,P_CALLED_FROM,P_ADDR_VAL_LEVEL,x_addr_warn_msg,''S'',x_status);');
        l(' ');
        l('      IF P_LOCATION_ID IS NOT NULL THEN');
        l('          HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                     L_USAGE_CODE,''S'',L_LOC_COMPONENTS_REC,p_lock_flag,L_MDU_TBL,l_status);');
        l('      END IF;');
        l(' ');
        l('      x_status := FND_API.g_ret_sts_success;');
        l('      RETURN;');
        l('    END IF;');
        l('    --hk_debugl(''L_MDU_TBL has count count more than 1'');');
        l(' ');

        l_open_cur := NULL;
        l_fetch_cur:= NULL;

        j := 0;
        IF G_MAP_DTLS_TBL.COUNT > 0 THEN
          j := G_MAP_DTLS_TBL.FIRST;
          LOOP
            IF j>1 THEN
              l_fetch_cur := l_fetch_cur||',LL_MAP_DTLS_TBL('||j||').GEOGRAPHY_ID';
            END IF;
            EXIT WHEN j = G_MAP_DTLS_TBL.LAST;
            j := G_MAP_DTLS_TBL.NEXT(j);
          END LOOP;
        END IF;

        j := 0;
        IF L_MDU_TBL.COUNT > 0 THEN
          j := L_MDU_TBL.FIRST;
          LOOP
            IF j>1 THEN
              l('    l_value'||j||' := NVL(L_MDU_TBL('||j||').LOC_COMPVAL,''X'') ;');
              l('    IF l_value'||j||' = ''X'' THEN');
              l('      l_type'||j||' := ''X'';');
              l('    ELSE');
              l('      l_type'||j||' := L_MDU_TBL('||j||').GEOGRAPHY_TYPE;');
              l('      -- store the geography_type of the lowest address component that has a value passed in');
              l('      l_geography_type := l_type'||j||';');
              l('    END IF;');
              l(' ');
              l_open_cur := l_open_cur||',l_type'||j||',l_value'||j;
            END IF;

            EXIT WHEN j = L_MDU_TBL.LAST;
            j := L_MDU_TBL.NEXT(j);
          END LOOP;
        END IF;
        l(' ');
        l_open_cur := l_open_cur||',l_geography_type;';
        l_fetch_cur := l_fetch_cur||';';

        l('     LL_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
        l('     l_sql := HZ_GNR_UTIL_PKG.getQuery(L_MAP_DTLS_TBL,L_MDU_TBL,x_status);');
        l('     --hk_debugl(''The SQL query'');');
        l('     --hk_debugl(l_sql);');
        l(' ');
        l('     IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('       hz_utility_v2pub.debug ');
        l('            (p_message      => '' The SQL query : ''||l_sql,');
        l('             p_prefix        => l_debug_prefix,');
        l('             p_msg_level     => fnd_log.level_statement,');
        l('             p_module_prefix => l_module_prefix,');
        l('             p_module        => l_module');
        l('            );');
        l('     END IF; ');
        l(' ');
        l('     OPEN  c_getGeo FOR l_sql USING G_MAP_REC.COUNTRY_CODE,g_country_geo_id');
        l('           '||l_open_cur);
        l('     FETCH c_getGeo INTO l_geography_id,l_multiple_parent_flag,LL_MAP_DTLS_TBL(1).GEOGRAPHY_ID');
        l('           '||l_fetch_cur);
        l('     IF c_getGeo%NOTFOUND THEN ');
        l('       --hk_debugl(''No Match found for the usage level search'');');
        l(' ');
        l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('         hz_utility_v2pub.debug ');
        l('              (p_message      => '' No Match found for the usage level search '',');
        l('               p_prefix        => l_debug_prefix,');
        l('               p_msg_level     => fnd_log.level_statement,');
        l('               p_module_prefix => l_module_prefix,');
        l('               p_module        => l_module');
        l('              );');
        l('       END IF; ');
        l(' ');
        l('       HZ_GNR_UTIL_PKG.fix_no_match(LL_MAP_DTLS_TBL,x_status);');
        l('       x_status := FND_API.G_RET_STS_ERROR;');
        l('     ELSE ');
        l('       --Fetching once more to see where there are multiple records');
        l(' ');
        l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('         hz_utility_v2pub.debug ');
        l('              (p_message      => '' Fetching once more to see where there are multiple records '',');
        l('               p_prefix        => l_debug_prefix,');
        l('               p_msg_level     => fnd_log.level_statement,');
        l('               p_module_prefix => l_module_prefix,');
        l('               p_module        => l_module');
        l('              );');
        l('       END IF; ');
        l(' ');
        l('       FETCH c_getGeo INTO l_geography_id,l_multiple_parent_flag,LL_MAP_DTLS_TBL(1).GEOGRAPHY_ID');
        l('           '||l_fetch_cur);
        l('       IF c_getGeo%FOUND THEN -- not able to identify a unique record');
        l(' ');
        l('         -- Get the query again with identifier type as NAME if multiple match found');
        l('         -- If it returns a record, we are able to derive a unique record for identifier type as NAME');
        l('         l_sql := HZ_GNR_UTIL_PKG.getQueryforMultiMatch(L_MAP_DTLS_TBL,L_MDU_TBL,x_status);');
        l('         OPEN  c_getGeo1 FOR l_sql USING G_MAP_REC.COUNTRY_CODE,g_country_geo_id');
        l('               '||l_open_cur);
        l(' ');
        l('         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('           hz_utility_v2pub.debug ');
        l('                (p_message      => ''Before the fetch of the query with identifier type as NAME after multiple match found'',');
        l('                 p_prefix        => l_debug_prefix,');
        l('                 p_msg_level     => fnd_log.level_statement,');
        l('                 p_module_prefix => l_module_prefix,');
        l('                 p_module        => l_module');
        l('                );');
        l('         END IF; ');
        l(' ');
        l('     --hk_debugt(LL_MAP_DTLS_TBL);');
        l('         FETCH c_getGeo1 INTO l_geography_id,l_multiple_parent_flag,LL_MAP_DTLS_TBL(1).GEOGRAPHY_ID');
        l('               '||l_fetch_cur);
        l('         IF c_getGeo1%FOUND THEN  ');
        ---- Fix for Bug 5011366 (Nishant)
        l('           -- check if there is another row with same STANDARD_NAME, in that case it is error case ');
        l('           FETCH c_getGeo1 INTO l_geography_id,l_multiple_parent_flag,L_MAP_DTLS_TBL(1).GEOGRAPHY_ID ');
        l('                '||l_fetch_cur);
        l('           IF c_getGeo1%NOTFOUND THEN  -- success (only 1 rec with same primary name exists)' );
        l(' ');
        l('             IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('                hz_utility_v2pub.debug ');
        l('                    (p_message       => ''GEO-Able to find a unique record or a record with multiple parent flag = Y with identifier type as NAME'',');
        l('                     p_prefix        => l_debug_prefix,');
        l('                     p_msg_level     => fnd_log.level_statement,');
        l('                     p_module_prefix => l_module_prefix,');
        l('                     p_module        => l_module');
        l('                    );');
        l('             END IF; ');
        l(' ');
        l('           ELSE -- Not able to find a unique record with identifier type as NAME ');
        l(' ');
        l('               IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('	                 hz_utility_v2pub.debug ');
        l('	                      (p_message      => ''GEO-Not able to find a record with with identifier type as NAME. ''|| ');
        l('	                                         '' More than 1 rec exists with same STANDARD NAME'', ');
        l('	                       p_prefix        => l_debug_prefix, ');
        l('	                       p_msg_level     => fnd_log.level_statement, ');
        l('	                       p_module_prefix => l_module_prefix, ');
        l('	                       p_module        => l_module ');
        l('	                      ); ');
        l('	               END IF; ');
        l(' ');
        l('               LL_MAP_DTLS_TBL       := L_MAP_DTLS_TBL; ');
        l('               HZ_GNR_UTIL_PKG.fix_no_match(LL_MAP_DTLS_TBL,x_status); ');
        l('               x_status := FND_API.G_RET_STS_ERROR; ');
        l('	          END IF; ');
        l(' ');
        ----- End of fix for Bug 5011366 (Nishant)
        l('         ELSE -- Not able to found a unique record with identifier type as NAME');
        l(' ');
        l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('             hz_utility_v2pub.debug ');
        l('                  (p_message      => '' Not able to find a record with with identifier type as NAME. '',');
        l('                   p_prefix        => l_debug_prefix,');
        l('                   p_msg_level     => fnd_log.level_statement,');
        l('                   p_module_prefix => l_module_prefix,');
        l('                   p_module        => l_module');
        l('                  );');
        l('           END IF; ');
        l(' ');
        l('           LL_MAP_DTLS_TBL       := L_MAP_DTLS_TBL;');
        l('           x_status := FND_API.G_RET_STS_ERROR;');
        l('         END IF; ');
        l('         CLOSE c_getGeo1;');
        l(' ');
        l('       ELSE -- a unique record or a record with multiple parent flag = Y is found');
        l(' ');
        l('         IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('           hz_utility_v2pub.debug ');
        l('                (p_message      => '' A unique record or a record with multiple parent flag = Y is found '',');
        l('                 p_prefix        => l_debug_prefix,');
        l('                 p_msg_level     => fnd_log.level_statement,');
        l('                 p_module_prefix => l_module_prefix,');
        l('                 p_module        => l_module');
        l('                );');
        l('         END IF; ');
        l(' ');
        l('       END IF;');
        l(' ');
        l('       IF l_multiple_parent_flag = ''Y''  AND x_status <> FND_API.G_RET_STS_ERROR THEN');
        l('         IF HZ_GNR_UTIL_PKG.fix_multiparent(l_geography_id,LL_MAP_DTLS_TBL) = TRUE THEN');
        l('           NULL;');
        l('         ELSE --  Multiple parent case not able to find a unique record ');
        l(' ');
        l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('             hz_utility_v2pub.debug ');
        l('                  (p_message      => '' Multiple parent case not able to find a unique record'',');
        l('                   p_prefix        => l_debug_prefix,');
        l('                   p_msg_level     => fnd_log.level_statement,');
        l('                   p_module_prefix => l_module_prefix,');
        l('                   p_module        => l_module');
        l('                  );');
        l('           END IF; ');
        l(' ');
        l('           x_status := FND_API.G_RET_STS_ERROR;');
        l('         END IF;');
        l(' ');
        l('       ELSE -- a unique record is found');
        l(' ');
        l('           IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('             hz_utility_v2pub.debug ');
        l('                  (p_message      => '' A unique record is found '',');
        l('                   p_prefix        => l_debug_prefix,');
        l('                   p_msg_level     => fnd_log.level_statement,');
        l('                   p_module_prefix => l_module_prefix,');
        l('                   p_module        => l_module');
        l('                  );');
        l('           END IF; ');
        l(' ');
        l('       END IF;');
        l('     END IF;');
        l('     CLOSE c_getGeo;');
        l(' ');
        l('      --hk_debugl(''Return STatus after first fetch : ''||x_status);');
        l('     --Following call will try to derive missing lower level compoents  ');
        l(' ');
        l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('         hz_utility_v2pub.debug ');
        l('              (p_message      => '' Return Status after first fetch : ''||x_status,');
        l('               p_prefix        => l_debug_prefix,');
        l('               p_msg_level     => fnd_log.level_statement,');
        l('               p_module_prefix => l_module_prefix,');
        l('               p_module        => l_module');
        l('              );');
        l('       END IF; ');
        l(' ');
        l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('         hz_utility_v2pub.debug ');
        l('              (p_message      => '' Calling fix_child. This call will try to derive missing lower level compoents.'',');
        l('               p_prefix        => l_debug_prefix,');
        l('               p_msg_level     => fnd_log.level_statement,');
        l('               p_module_prefix => l_module_prefix,');
        l('               p_module        => l_module');
        l('              );');
        l('       END IF; ');
        l(' ');
        l('     IF HZ_GNR_UTIL_PKG.fix_child(LL_MAP_DTLS_TBL) = FALSE THEN');
        l('       x_status := HZ_GNR_UTIL_PKG.get_usage_val_status(LL_MAP_DTLS_TBL,L_MDU_TBL);');
        l('     END IF;');
        l(' ');
        l('       IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('         hz_utility_v2pub.debug ');
        l('              (p_message      => '' Return status after fix_child ''||x_status,');
        l('               p_prefix        => l_debug_prefix,');
        l('               p_msg_level     => fnd_log.level_statement,');
        l('               p_module_prefix => l_module_prefix,');
        l('               p_module        => l_module');
        l('              );');
        l('       END IF; ');
        l(' ');
        l('      --hk_debugl(''LL_MAP_DTLS_TBL before fill_values'');');
        l('      --hk_debugt(LL_MAP_DTLS_TBL);');
        l('     HZ_GNR_UTIL_PKG.fill_values(LL_MAP_DTLS_TBL);');
        l('      --hk_debugl(''LL_MAP_DTLS_TBL after fill_values'');');
        l('      --hk_debugt(LL_MAP_DTLS_TBL);');
        l(' ');
        l('    IF x_status = FND_API.g_ret_sts_success THEN');
        l('      -- We need to call the getAddrValStatus only once. All other cases we are looking into x_call_map ');
        l('      -- In some case the below code will execute with the x_call_map as N  ');
        l('      IF l_get_addr_val = ''Y'' THEN');
        l('         -- This below call is to derive the address validation status and set the message ');
        l('         X_ADDR_VAL_STATUS := HZ_GNR_UTIL_PKG.getAddrValStatus(LL_MAP_DTLS_TBL,L_MDU_TBL,P_CALLED_FROM,P_ADDR_VAL_LEVEL,x_addr_warn_msg,x_status,x_status);');
        l('      END IF;');
        l(' ');
        l('      IF P_LOCATION_ID IS NOT NULL THEN');
        l(' ');
        l('              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('                hz_utility_v2pub.debug ');
        l('                     (p_message      => '' Calling create_gnr with map status S.'',');
        l('                      p_prefix        => l_debug_prefix,');
        l('                      p_msg_level     => fnd_log.level_statement,');
        l('                      p_module_prefix => l_module_prefix,');
        l('                      p_module        => l_module');
        l('                     );');
        l('              END IF; ');
        l(' ');
        l('        HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                   L_USAGE_CODE,''S'',L_LOC_COMPONENTS_REC,p_lock_flag,LL_MAP_DTLS_TBL,l_status);');
        l('      --hk_debugl(''Prceossed GNR With Status : S and returned with Status : ''||l_status);');
        l('      END IF;');
        l('    ELSE ');
        l('      -- We need to call the getAddrValStatus only once. All other cases we are looking into x_call_map ');
        l('      -- In some case the below code will execute with the x_call_map as N  ');
        l('      IF l_get_addr_val = ''Y'' THEN');
        l('         -- This below call is to derive the address validation status and set the message ');
        l('         X_ADDR_VAL_STATUS := HZ_GNR_UTIL_PKG.getAddrValStatus(LL_MAP_DTLS_TBL,L_MDU_TBL,P_CALLED_FROM,P_ADDR_VAL_LEVEL,x_addr_warn_msg,x_status,x_status);');
        l('      END IF;');
        l(' ');
        l('      IF P_LOCATION_ID IS NOT NULL THEN');
        l(' ');
        l('              IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('                hz_utility_v2pub.debug ');
        l('                     (p_message      => '' Calling create_gnr with map status E.'',');
        l('                      p_prefix        => l_debug_prefix,');
        l('                      p_msg_level     => fnd_log.level_statement,');
        l('                      p_module_prefix => l_module_prefix,');
        l('                      p_module        => l_module');
        l('                     );');
        l('              END IF; ');
        l(' ');
        l('        HZ_GNR_UTIL_PKG.create_gnr(P_LOCATION_ID,G_MAP_REC.LOC_TBL_NAME,');
        l('                                     L_USAGE_CODE,''E'',L_LOC_COMPONENTS_REC,p_lock_flag,LL_MAP_DTLS_TBL,l_status);');
        l('        --hk_debugl(''Prceossed GNR With Status : E and returned with Status : ''||l_status);');
        l('      END IF;');
        l('    END IF;');
        l(' ');
        l('    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN ');
        l('      hz_utility_v2pub.debug ');
        l('           (p_message      => ''End of validation for ''||L_USAGE_CODE,');
        l('            p_prefix        => l_debug_prefix,');
        l('            p_msg_level     => fnd_log.level_procedure,');
        l('            p_module_prefix => l_module_prefix,');
        l('            p_module        => l_module');
        l('           );');
        l('    END IF; ');
        l(' ');
        l('            --hk_debugt(LL_MAP_DTLS_TBL); ----- Code to display the output.');
        ---- end procedure
        procEnd(l_procName);
        EXIT WHEN i = G_USAGE_TBL.LAST;
        i := G_USAGE_TBL.NEXT(i);
      END LOOP;
    END IF;

  END validateBody;
  --------------------------------------
  PROCEDURE genSpec(
   x_status OUT NOCOPY VARCHAR2) IS
     l_count      number;
     l_procName   varchar2(10);
     l_tmp        varchar2(4);

   BEGIN
     -- flow
     -- 1. create the package header
     -- 2. generate spec for srchGeo()
     -- 3. create the package tail
     --

     -- initializing the retun value
     x_status := FND_API.G_RET_STS_SUCCESS;

     genPkgSpecHdr(g_pkgName);
     -- known caveat: for srchGeoSpec - the procedure comments do not have all the
     -- input variables.
     IF g_map_rec.LOC_TBL_NAME = 'HR_LOCATIONS_ALL' THEN
       validateHrSpec();
     END IF;
     IF g_map_rec.LOC_TBL_NAME = 'HZ_LOCATIONS' THEN
       get_usage_API_Spec;
       validateSpec();
     END IF;
     genPkgSpecTail(g_pkgName);


   END genSpec;
  --------------------------------------
  PROCEDURE genBody(
   x_status OUT NOCOPY  VARCHAR2) IS

    l_count      number;
    i            number;
    l_procName   varchar2(10);
    l_tmp        varchar2(4);
    l_level      number;

  BEGIN
    /* flow
    1. Generate the package header
    2. validateBody()
    3. generate the package tail
    */

    -- initializing the retun value
    x_status := FND_API.G_RET_STS_SUCCESS;

    -- package header
    genPkgBdyHdr(g_pkgName);

    ---- writing the global variables
    li('--------------------------------------');
    li(' -- declaration of private global varibles');
    li(' --------------------------------------');
    l(' ');
    li(' g_debug_count        NUMBER := 0;');
    li(' g_country_geo_id     NUMBER;');
    li(' G_MAP_REC            HZ_GNR_UTIL_PKG.MAP_REC_TYPE;');
    li(' G_MAP_DTLS_TBL       HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
    li(' G_USAGE_TBL          HZ_GNR_UTIL_PKG.USAGE_TBL_TYPE;');
    li(' G_USAGE_DTLS_TBL     HZ_GNR_UTIL_PKG.USAGE_DTLS_TBL_TYPE;');
    -- create global variables with mapping details per usage
    i:=0;
    IF G_USAGE_TBL.COUNT > 0 THEN
      i := G_USAGE_TBL.FIRST;
      LOOP
        li(' G_MDU_TBL'||G_USAGE_TBL(i).USAGE_ID||'       HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;');
        EXIT WHEN i = G_USAGE_TBL.LAST;
        i := G_USAGE_TBL.NEXT(i);
      END LOOP;
    END IF;
    l(' ');
    li(' --------------------------------------');
    li(' -- declaration of private procedures and functions');
    li(' --------------------------------------');
    l(' ');
    li(' --------------------------------------');
    li(' -- private procedures and functions');
    li(' --------------------------------------');
    l(' ');

    IF g_map_rec.LOC_TBL_NAME = 'HZ_LOCATIONS' THEN
      get_usage_API_Body;
      validateBody(x_status);
    END IF;
    IF g_map_rec.LOC_TBL_NAME = 'HR_LOCATIONS_ALL' THEN
      validateHrBody(x_status);
    END IF;

    genPkgBdyInit(x_status);
    -- write the pkg end
    genPkgBdyTail(g_pkgName);
  END genBody;

  --------------------------------------
    -- procedures and functions
  --------------------------------------
  --------------------------------------
  /**
   * PROCEDURE genPkg
   *
   * DESCRIPTION
   *     This private procedure is used to generate map specific  package with
   *     GNR search procedures
   *
   *
   * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
   *
   * ARGUMENTS
   *   IN:
   *
   *     p_map_rec          Mapping Record
   *     p_map_dtls_tbl     table of records of map details
   *     p_usage_tbl        Table of records of Usages
   *     p_usage_dtls_tbl   Table of records of all usages and their details populated for usage after other.
   *
   *   OUT:
   *
   *   x_pkgName  generated package name
   *   x_status   indicates if the genPkg was sucessfull or not.
   *
   * NOTES
   *
   *
   * MODIFICATION HISTORY
   *
   *
   */
  --------------------------------------
    procedure genPkg(
      p_map_rec          IN  HZ_GNR_UTIL_PKG.map_rec_type,
      p_map_dtls_tbl     IN  HZ_GNR_UTIL_PKG.maploc_rec_tbl_type,
      p_usage_tbl        IN  HZ_GNR_UTIL_PKG.usage_tbl_type,
      p_usage_dtls_tbl   IN  HZ_GNR_UTIL_PKG.usage_dtls_tbl_type,
      x_pkgName          OUT NOCOPY VARCHAR2,
      x_status           OUT NOCOPY VARCHAR2) IS

    BEGIN

      -- flow
      --   prepare the packge name
      --   genSpec()
      --   genBody()

  -- Hari 2 Lines
  g_type  := 'S';
      -- initializing the retun value
       x_status := FND_API.G_RET_STS_SUCCESS;

      --   prepare the packge name
      x_pkgName          := 'HZ_GNR_MAP'||p_map_rec.map_id;
      g_map_rec          := p_map_rec;
      g_map_dtls_tbl     := p_map_dtls_tbl;
      g_usage_tbl        := p_usage_tbl;
      g_usage_dtls_tbl   := p_usage_dtls_tbl;
      g_pkgName          := x_pkgName;

      genSpec(x_status);
      IF x_status <> FND_API.G_RET_STS_SUCCESS THEN
         --dbms_output.put_line('genSpec in genPkg'||sqlerrm);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  -- Hari 1 Line
  g_type  := 'B';
      genBody(x_status);
      IF x_status <> FND_API.G_RET_STS_SUCCESS THEN
         --dbms_output.put_line('genBody in genPkg'||sqlerrm);
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  END genPkg;
  --------------------------------------
  procedure genPkg(
    p_map_id           IN  NUMBER,
    x_pkgName          OUT NOCOPY VARCHAR2,
    x_status           OUT NOCOPY VARCHAR2) IS

    m number := 0;
    n number := 0;

    l_map_rec          HZ_GNR_UTIL_PKG.MAP_REC_TYPE;
    l_map_dtls_tbl     HZ_GNR_UTIL_PKG.MAPLOC_REC_TBL_TYPE;
    l_usage_tbl        HZ_GNR_UTIL_PKG.USAGE_TBL_TYPE;
    l_usage_dtls_tbl   HZ_GNR_UTIL_PKG.USAGE_DTLS_TBL_TYPE;

    CURSOR c_map(p_map_id IN NUMBER) IS
    SELECT MAP_ID,COUNTRY_CODE,LOC_TBL_NAME,ADDRESS_STYLE
    FROM   hz_geo_struct_map
    WHERE  map_id = p_map_id;

    CURSOR c_map_dtls(p_map_id IN NUMBER) IS
    SELECT MAP_ID,LOC_SEQ_NUM,LOC_COMPONENT,GEOGRAPHY_TYPE,GEO_ELEMENT_COL
    FROM   hz_geo_struct_map_dtl
    WHERE  map_id = p_map_id
    ORDER  BY LOC_SEQ_NUM;

    CURSOR c_usage(p_map_id IN NUMBER) IS
    SELECT MAP_ID,USAGE_ID,USAGE_CODE
    FROM   hz_address_usages
    WHERE  map_id = p_map_id
    AND    status_flag = 'A'
    ORDER BY usage_id;

    CURSOR c_usage_dtls(p_usage_id IN NUMBER) IS
    SELECT udtl.USAGE_ID,udtl.GEOGRAPHY_TYPE
    FROM   hz_address_usage_dtls udtl
    WHERE  USAGE_ID = p_usage_id;

    l_map_exists        varchar2(1);
    l_map_dtls_exists   varchar2(1);
    l_usage_exists      varchar2(1);
    l_usage_dtls_exists varchar2(1);

  BEGIN
    -- initializing the retun value
    x_status := FND_API.G_RET_STS_SUCCESS;
    l_map_exists := 'N';
    FOR l_c_map IN c_map(p_map_id) LOOP -- only one record will be fetched
      l_map_exists := 'Y';
      l_map_rec.MAP_ID           := l_c_map.MAP_ID;
      l_map_rec.COUNTRY_CODE     := l_c_map.COUNTRY_CODE;
      l_map_rec.LOC_TBL_NAME     := l_c_map.LOC_TBL_NAME;
      l_map_rec.ADDRESS_STYLE    := l_c_map.ADDRESS_STYLE;
      l_map_dtls_exists := 'N';
      FOR l_c_map_dtls IN c_map_dtls(p_map_id) LOOP
        l_map_dtls_exists := 'Y';
        m := m+1;
        l_map_dtls_tbl(m).loc_seq_num     := l_c_map_dtls.loc_seq_num;
        l_map_dtls_tbl(m).loc_component   := l_c_map_dtls.loc_component;
        l_map_dtls_tbl(m).geography_type  := l_c_map_dtls.geography_type;
        l_map_dtls_tbl(m).geo_element_col := l_c_map_dtls.geo_element_col;
        l_map_dtls_tbl(m).loc_compval     := null;
        l_map_dtls_tbl(m).geography_id    := null;
      END LOOP;
      IF l_map_dtls_exists = 'N' THEN
         x_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      m :=0;
      l_usage_exists := 'N';
      FOR l_c_usage in c_usage(p_map_id) LOOP
        l_usage_exists := 'Y';
        m := m+1;
        l_usage_tbl(m).USAGE_ID           := l_c_usage.USAGE_ID;
        l_usage_tbl(m).MAP_ID             := l_c_usage.MAP_ID;
        l_usage_tbl(m).USAGE_CODE         := l_c_usage.USAGE_CODE;
        l_usage_dtls_exists := 'N';
        FOR l_c_usage_dtls IN c_usage_dtls(l_c_usage.usage_id) LOOP
          l_usage_dtls_exists := 'Y';
          n := n+1;
          l_usage_dtls_tbl(n).USAGE_ID       := l_c_usage_dtls.USAGE_ID;
          l_usage_dtls_tbl(n).GEOGRAPHY_TYPE := l_c_usage_dtls.GEOGRAPHY_TYPE;
        END LOOP;
        IF l_usage_dtls_exists = 'N' THEN
           x_status := FND_API.G_RET_STS_ERROR;
           RAISE FND_API.G_EXC_ERROR;
        END IF;
      END LOOP;
      IF l_usage_exists = 'N' THEN
         x_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    END LOOP;
    IF l_map_exists = 'N' THEN
       x_status := FND_API.G_RET_STS_ERROR;
       RAISE FND_API.G_EXC_ERROR;
    END IF;

    genpkg(l_map_rec,l_map_dtls_tbl,l_usage_tbl,l_usage_dtls_tbl,x_pkgname,x_status);
  END genPkg;
END HZ_GNR_GEN_PKG;


/
