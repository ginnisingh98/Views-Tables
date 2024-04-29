--------------------------------------------------------
--  DDL for Package Body PJM_PJMRPWSE_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PJMRPWSE_XMLP_PKG" AS
/* $Header: PJMRPWSEB.pls 120.0 2007/12/24 12:29:48 nchinnam noship $ */
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;


  function BeforeReport return boolean is
  begin

    --SRW.USER_EXIT('FND SRWINIT');

    select meaning
    into   P_order_by_disp
    from   mfg_lookups
    where  lookup_type = 'PJM_SCHEDEXC_ORDERBY'
    and    lookup_code = P_order_by;

  /*  SRW.USER_EXIT('FND FLEXSQL
              CODE="MSTK"
              APPL_SHORT_NAME="INV"
              MODE="WHERE"
              OUTPUT=":P_ITEM_WHERE"
              OPERATOR="BETWEEN"
              OPERAND1=":P_ASSEMBLY_FROM"
              OPERAND2=":P_ASSEMBLY_TO"
              TABLEALIAS="MIF"');*/

    --
    -- Building project range where clause
    --
    IF ( P_PROJECT_NUMBER_FROM IS NOT NULL ) THEN

      IF ( P_PROJECT_NUMBER_TO IS NOT NULL ) THEN
        P_PROJECT_WHERE :=
           'PP.SEGMENT1 BETWEEN ''' || P_PROJECT_NUMBER_FROM || '''' ||
           ' AND ''' || P_PROJECT_NUMBER_TO || '''' ;
      ELSE
        P_PROJECT_WHERE := 'PP.SEGMENT1 >= ''' || P_PROJECT_NUMBER_FROM || '''';
      END IF;

    ELSE

      IF ( P_PROJECT_NUMBER_TO IS NOT NULL ) THEN
        P_PROJECT_WHERE := 'PP.SEGMENT1 <= ''' || P_PROJECT_NUMBER_TO || '''';
      ELSE
        P_PROJECT_WHERE := '1 = 1 ';
      END IF;

    END IF;

    --
    -- Building date range where clause
    --
    D_DATE_FROM      := FND_DATE.CANONICAL_TO_DATE(P_DATE_FROM);
    D_DATE_TO        := FND_DATE.CANONICAL_TO_DATE(P_DATE_TO);
    D_DATE_FROM_DISP := FND_DATE.DATE_TO_DISPLAYDATE(D_DATE_FROM);
    D_DATE_TO_DISP   := FND_DATE.DATE_TO_DISPLAYDATE(D_DATE_TO);

    IF ( P_DATE_FROM IS NOT NULL ) THEN

      IF ( P_DATE_TO IS NOT NULL ) THEN
        P_DATE_WHERE := ' BETWEEN TO_DATE(''' || D_DATE_FROM ||
                         ''', ''YYYY/MM/DD'') AND TO_DATE(''' || D_DATE_TO || ''', ''YYYY/MM/DD'')';
      ELSE
        P_DATE_WHERE := ' >= TO_DATE(''' || D_DATE_FROM || ''', ''YYYY/MM/DD'')';
      END IF;

    ELSE

      IF ( P_DATE_TO IS NOT NULL ) THEN
        P_DATE_WHERE := ' <= TO_DATE(''' || D_DATE_TO || ''', ''YYYY/MM/DD'')';
      ELSE
        P_DATE_WHERE := ' IS NOT NULL ';
      END IF;

    END IF;


    return (TRUE);
end;

END PJM_PJMRPWSE_XMLP_PKG;


/
