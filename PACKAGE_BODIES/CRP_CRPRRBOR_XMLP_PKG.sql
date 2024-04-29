--------------------------------------------------------
--  DDL for Package Body CRP_CRPRRBOR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CRP_CRPRRBOR_XMLP_PKG" AS
/* $Header: CRPRRBORB.pls 120.2 2007/12/25 07:01:55 nchinnam noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
      /*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK"
                                                 APPL_SHORT_NAME="INV"
                                                 OUTPUT=":P_FLEXDATA"
                                                 MODE="SELECT"
                                                 DISPLAY="ALL"
                                                 NUM="101"
                                                 TABLEALIAS="sys"')*/NULL;
      IF ((P_LOW_ITEM IS NOT NULL) OR (P_HIGH_ITEM IS NOT NULL)) THEN
        NULL;
      END IF;
    END;
    RETURN (TRUE);
  END BEFOREREPORT;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

  FUNCTION C_RSRC_SET_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      R_SET VARCHAR2(200);
    BEGIN
      R_SET := 'and br.bill_of_resources = rs.bill_of_resources ' || 'and br.organization_id = rs.organization_id ' || 'and br.bill_of_resources = ''' || P_RESOURCE_SET || '''';
      RETURN (R_SET);
    END;
    RETURN NULL;
  END C_RSRC_SET_WHEREFORMULA;

  FUNCTION C_RSRC_USE_WHEREFORMULA RETURN VARCHAR2 IS
  BEGIN
    DECLARE
      R_USE VARCHAR2(80);
    BEGIN
      IF (P_RESOURCE_USE IS NOT NULL) THEN
        R_USE := 'and dr.resource_group_name = ''' || P_RESOURCE_USE || ''' ';
      ELSE
        R_USE := 'and 1=1';
      END IF;
      RETURN (R_USE);
    END;
    RETURN NULL;
  END C_RSRC_USE_WHEREFORMULA;

  PROCEDURE GET_PRECISION IS
  BEGIN
  /*   SRW.ATTR.MASK := SRW.FORMATMASK_ATTR;
    IF P_QTY_PRECISION = 0 THEN
      SRW.ATTR.FORMATMASK := '-NNN,NNN,NNN,NN0';
    ELSE
      IF P_QTY_PRECISION = 1 THEN
        SRW.ATTR.FORMATMASK := '-NNN,NNN,NNN,NN0.0';
      ELSE
        IF P_QTY_PRECISION = 3 THEN
          SRW.ATTR.FORMATMASK := '-NN,NNN,NNN,NN0.000';
        ELSE
          IF P_QTY_PRECISION = 4 THEN
            SRW.ATTR.FORMATMASK := '-N,NNN,NNN,NN0.0000';
          ELSE
            IF P_QTY_PRECISION = 5 THEN
              SRW.ATTR.FORMATMASK := '-NNN,NNN,NN0.00000';
            ELSE
              IF P_QTY_PRECISION = 6 THEN
                SRW.ATTR.FORMATMASK := '-NN,NNN,NN0.000000';
              ELSE
                SRW.ATTR.FORMATMASK := '-NNN,NNN,NNN,NN0.00';
              END IF;
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;*/
    /*SRW.SET_ATTR(0
                ,SRW.ATTR)*/NULL;
  END GET_PRECISION;

END CRP_CRPRRBOR_XMLP_PKG;


/
