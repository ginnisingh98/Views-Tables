--------------------------------------------------------
--  DDL for Package Body PJM_PJMRPSEP_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_PJMRPSEP_XMLP_PKG" AS
/* $Header: PJMRPSEPB.pls 120.0 2007/12/24 12:27:49 nchinnam noship $ */

  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN

	/*SRW.USER_EXIT('FND SRWINIT');*/

	  select meaning
	  into   P_ORDER_BY_DISP
	  from   mfg_lookups
	  where  lookup_type = 'PJM_SCHEDEXC_ORDERBY'
	  and    lookup_code = P_order_by;

	 /* if (P_prt_po <> 'Y') then
	     srw.SET_MAXROW('Q_PO',0);
	  end if;

	  if (P_prt_rel <> 'Y') then
	     srw.SET_MAXROW('Q_REL',0);
	  end if;

	  if (P_prt_pr <> 'Y') then
	     srw.SET_MAXROW('Q_PR',0);
	  end if;

	  if (P_prt_rfq <> 'Y') then
	     srw.SET_MAXROW('Q_RFQ',0);
	  end if;

	  if (P_prt_qtn <> 'Y') then
	     srw.SET_MAXROW('Q_QTN',0);
	  end if; */

  /*SRW.USER_EXIT('FND FLEXSQL
            CODE="MSTK"
            APPL_SHORT_NAME="INV"
            MODE="WHERE"
            OUTPUT=":P_ITEM_WHERE"
            OPERATOR="BETWEEN"
            OPERAND1=":P_ITEM_FROM"
            OPERAND2=":P_ITEM_TO"
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

	LP_ORDER_BY_DISP:=P_ORDER_BY_DISP;


	RETURN (TRUE);
  END;



  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;

	Function Filter_G_PO return Boolean IS
	BEGIN
		if (P_prt_po <> 'Y') then
			return (FALSE);
		end if;
	 RETURN (TRUE);
	END Filter_G_PO;

	Function Filter_G_REL return Boolean IS
	BEGIN
		if (P_prt_rel <> 'Y') then
			return (FALSE);
		end if;
	 RETURN (TRUE);
	END Filter_G_REL;

	Function Filter_G_PR return Boolean IS
	BEGIN
		 if (P_prt_pr <> 'Y') then
			return (FALSE);
		 end if;
	  RETURN (TRUE);
	END Filter_G_PR;

	Function Filter_G_RFQ return Boolean IS
	BEGIN

		if (P_prt_rfq <> 'Y') then
			return (FALSE);
		end if;
	  RETURN (TRUE);
	END Filter_G_RFQ;

	Function Filter_G_QTN return Boolean IS
	BEGIN

		if (P_prt_qtn <> 'Y') then
			return (FALSE);
		end if;

	  RETURN (TRUE);
	END Filter_G_QTN;

END PJM_PJMRPSEP_XMLP_PKG;


/
