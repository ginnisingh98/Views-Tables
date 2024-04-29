--------------------------------------------------------
--  DDL for Package Body GMF_COPY_PERCENTAGE_BURDEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_COPY_PERCENTAGE_BURDEN" AS
/* $Header: gmfcppbb.pls 120.3 2006/04/07 05:00:26 anthiyag noship $ */


   /*****************************************************************************
   * PACKAGE BODY                                                               *
   *    GMF_COPY_PERCENTAGE_BURDEN                                              *
   *                                                                            *
   * DESCRIPTION                                                                *
   *    Copy Percentage Burdens                                                 *
   *                                                                            *
   * CONTENTS                                                                   *
   *    PROCEDURE   copy_percentage_burden ( ... )                              *
   *    PROCEDURE end_copy ( ... )                                              *
   *    PROCEDURE copy_burden_pct ( ... )                                       *
   *    PROCEDURE delete_burden_pct ( ... )                                     *
   *    FUNCTION  do_pct_exist ( ... )                                          *
   *                                                                            *
   * HISTORY                                                                    *
   *    21-Nov-2000 Uday Moogala - Created                                      *
   *       Bug# 1419482 Percentage Burden Enhancements.                         *
   *       1. Copy to all periods option :                                      *
   *       Copy Percentage burden from one costing period to all the subsequent *
   *       open/frozen costing periods in the same calendar or                  *
   *       to all the open/frozen periods if it is a different calendar.        *
   *       For more details refer to DLD : pct_burden_dld.rtf                   *
   *    30-OCT-2002    RajaSekhar    Bug#2641405 Added NOCOPY hint.             *
   *****************************************************************************/

   PROCEDURE end_copy
   (
	pi_errstat	         IN             VARCHAR2,
	pi_errmsg	         IN             VARCHAR2
	);

   PROCEDURE copy_burden_pct
   (
   pi_legal_entity_id_from          IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_from	         IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_from	            IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_from	            IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_legal_entity_id_to            IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_to	            IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_to	               IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_to	            IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_from_range		               IN                gmf_burden_codes.burden_code%TYPE,
   pi_to_range		                  IN                gmf_burden_codes.burden_code%TYPE,
   pi_rem_repl		                  IN                NUMBER,
   pi_all_periods_from              IN                cm_cldr_dtl.period_code%TYPE,
   pi_all_periods_to                IN                cm_cldr_dtl.period_code%TYPE
	);

   PROCEDURE delete_burden_pct
   (
   pi_legal_entity_id            IN          gmf_burden_percentages.legal_entity_id%TYPE,
   pi_period_id                  IN          gmf_burden_percentages.period_id%TYPE,
   pi_cost_type_id               IN          cm_mthd_mst.cost_type_id%TYPE,
   pi_from_range		            IN          gmf_burden_codes.burden_code%TYPE,
   pi_to_range		               IN          gmf_burden_codes.burden_code%TYPE
	);

   FUNCTION do_pct_exist
   (
	pi_legal_entity_id               IN             gmf_burden_percentages.legal_entity_id%TYPE,
	pi_period_id                     IN             gmf_burden_percentages.period_id%TYPE,
	pi_cost_type_id                  IN             cm_mthd_mst.cost_type_id%TYPE,
	pi_burden_code_from              IN             gmf_burden_codes.burden_code%TYPE,
	pi_burden_code_to                IN             gmf_burden_codes.burden_code%TYPE
   )
   RETURN NUMBER ;

   /**************
   * WHO columns *
   **************/

   g_user_id	                     NUMBER;
   g_login_id	                     NUMBER;


   /*******************************************************************************
   * PROCEDURE                                                                    *
   *    copy_percentage_burden                                                    *
   *                                                                              *
   * DESCRIPTION                                                                  *
   *    Copy Copy Percentage Burdens                                              *
   *    Copies Burden Percentages from the one set of calendar/period/cost method *
   *    to another for the burden codes range specified on the form.              *
   *                                                                              *
   * INPUT PARAMETERS                                                             *
   *    From and To calendar/period/cost method                                   *
   *    Burden Codes from/to range                                                *
   *    Remove before copy or Replace during copy indicator                       *
   *                                                                              *
   * OUTPUT PARAMETERS                                                            *
   *    po_errbuf      Completion message to the Concurrent Manager               *
   *    po_retcode     Return code to the Concurrent Manager                      *
   *                                                                              *
   * HISTORY                                                                      *
   *    13-Oct-1999 Uday Moogala   Created                                        *
   *******************************************************************************/

   PROCEDURE copy_percentage_burden
   (
   po_errbuf		                     OUT NOCOPY     VARCHAR2,
   po_retcode		                     OUT NOCOPY     VARCHAR2,
   pi_legal_entity_id_from          IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_from            IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_from              IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_from             IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_legal_entity_id_to            IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_to              IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_to                IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_to               IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_burden_code_from              IN                gmf_burden_codes.burden_code%TYPE,
   pi_burden_code_to                IN                gmf_burden_codes.burden_code%TYPE,
   pi_rem_repl                      IN                VARCHAR2,
   pi_all_periods_from              IN                cm_cldr_dtl.period_code%TYPE,
   pi_all_periods_to                IN                cm_cldr_dtl.period_code%TYPE
   )
   IS

      /******************
      * Local Variables *
      ******************/

      l_from_range		            gmf_burden_codes.burden_code%TYPE;
      l_to_range		               gmf_burden_codes.burden_code%TYPE;
      l_rem_repl		               NUMBER;
      l_num_src_rows  	            NUMBER;  -- num rows in source period
      l_period_id_from              gmf_burden_percentages.period_id%TYPE;

      /*************
      * Exceptions *
      *************/

      e_same_from_to		            EXCEPTION;
      e_no_cost_rows		            EXCEPTION;
      e_no_brdn_range		         EXCEPTION;

   BEGIN

      /****************************************************
      * Uncomment the call below to write to a local file *
      ****************************************************/

      ----FND_FILE.PUT_NAMES('gmfcppb.log','gmfcppb.out','/sqlcom/log/dom1151');


   	gmf_util.msg_log( 'GMF_CPPB_START' );
   	gmf_util.msg_log( 'GMF_CPPB_SRCPARAM', nvl(pi_calendar_code_from, ' '), nvl(pi_period_code_from, ' '), nvl(TO_CHAR(pi_cost_type_id_from), ' '));
      gmf_util.msg_log( 'GMF_CPPB_TGTPARAM', nvl(pi_calendar_code_to, ' '), nvl(pi_period_code_to, ' '), nvl(TO_CHAR(pi_cost_type_id_to), ' '));
      gmf_util.msg_log( 'GMF_CPPB_BRDNRANGE', nvl(pi_burden_code_from, ' '), nvl(pi_burden_code_to, ' '));

   	IF ( (pi_period_code_to IS NULL) AND ((pi_all_periods_from IS NOT NULL) OR (pi_all_periods_to IS NOT NULL))) THEN

   		gmf_util.msg_log('GMF_CPIC_ALLPERIODS', nvl(pi_calendar_code_to, ' ')) ;
   		gmf_util.msg_log('GMF_CPIC_PERIODS_RANGE', nvl(pi_all_periods_from, ' '),nvl(pi_all_periods_to, ' '), nvl(pi_calendar_code_to, ' '));

   	END IF ;

   	l_rem_repl := 0;

   	IF ( pi_rem_repl = '1' ) THEN --Remove Before Copy

   		l_rem_repl := 1;
   		gmf_util.msg_log( 'GMF_CPIC_OPTREM' );

   	ELSE				-- Replace before copy

   		l_rem_repl := 0;
   		gmf_util.msg_log( 'GMF_CPIC_OPTREP' );

   	END IF;

   	gmf_util.log;

   	l_from_range := NULL;
   	l_to_range := NULL;

   	IF ((pi_burden_code_from IS NOT NULL) OR (pi_burden_code_to IS NOT NULL)) THEN

         l_from_range	:= pi_burden_code_from;
         l_to_range	:= pi_burden_code_to;

      ELSE

         gmf_util.msg_log( 'GMF_CPPB_NO_BRDN_RANGE' );
         RAISE e_no_brdn_range;

   	END IF;

    BEGIN
       SELECT         a.period_id
       INTO           l_period_id_from
       FROM           cm_cldr_mst_v a
       WHERE          a.legal_entity_id = pi_legal_entity_id_from
       AND            a.calendar_code = pi_calendar_code_from
       AND            a.period_code = pi_period_code_from
       AND            a.cost_type_id = pi_cost_type_id_from;
    EXCEPTION
       WHEN OTHERS THEN
          l_period_id_from := NULL;
    END;

    IF l_period_id_from IS NULL THEN
       gmf_util.msg_log( 'GMF_CP_NO_ROWS' );
       RAISE e_no_cost_rows;
    END IF;

      l_num_src_rows := do_pct_exist( pi_legal_entity_id_from, l_period_id_from, pi_cost_type_id_from, pi_burden_code_from, pi_burden_code_to);

      IF ( l_num_src_rows <= 0 ) THEN

         gmf_util.msg_log( 'GMF_CP_NO_ROWS' );
         RAISE e_no_cost_rows;

      END IF;

   	gmf_util.trace( 'Burden Codes Range : ' || l_from_range || ' - ' || l_to_range, 1 );

      /*************************
      * Initialize WHO columns *
      *************************/

   	g_user_id	:= FND_GLOBAL.USER_ID;
   	g_login_id	:= FND_GLOBAL.LOGIN_ID;

      /**************************************************************
      * If all parameters then burden percentages cannot be copied. *
      **************************************************************/

   	IF ((pi_period_code_from = pi_period_code_to) AND (pi_cost_type_id_from = pi_cost_type_id_to) AND (pi_calendar_code_from = pi_calendar_code_to)) THEN

         gmf_util.msg_log( 'GMF_CPPB_SAME_FROMTO' );
         RAISE e_same_from_to;

      ELSE

   		copy_burden_pct
         (
         pi_legal_entity_id_from,
   		pi_calendar_code_from,
         pi_period_code_from,
         pi_cost_type_id_from,
         pi_legal_entity_id_to,
   		pi_calendar_code_to,
         pi_period_code_to,
         pi_cost_type_id_to,
   		l_from_range,
         l_to_range,
         l_rem_repl,
   		pi_all_periods_from,
         pi_all_periods_to
   		);

   	END IF;

   	po_retcode := 0;
   	po_errbuf := NULL;
   	end_copy( 'NORMAL', NULL );
   	COMMIT;

   	gmf_util.log;
   	gmf_util.msg_log( 'GMF_CPPB_END' );

   EXCEPTION
   	WHEN e_no_cost_rows THEN
   		po_retcode := 0;
   		po_errbuf := NULL;
   		end_copy( 'NORMAL', NULL );

   	WHEN e_same_from_to THEN
   		po_retcode := 0;
   		po_errbuf := NULL;
   		end_copy( 'NORMAL', NULL );

   	WHEN e_no_brdn_range THEN
   		po_retcode := 0;
   		po_errbuf := NULL;
   		end_copy( 'NORMAL', NULL );

   	WHEN utl_file.invalid_path then
   		po_retcode := 3;
   		po_errbuf := 'Invalid path - '||to_char(SQLCODE) || ' ' || SQLERRM;
   		end_copy ('ERROR', NULL);

   	WHEN utl_file.invalid_mode then
   		po_retcode := 3;
   		po_errbuf := 'Invalid Mode - '||to_char(SQLCODE) || ' ' || SQLERRM;
   		end_copy ('ERROR', NULL);

   	WHEN utl_file.invalid_filehandle then
   		po_retcode := 3;
   		po_errbuf := 'Invalid filehandle - '||to_char(SQLCODE) || ' ' || SQLERRM;
   		end_copy ('ERROR', NULL);

   	WHEN utl_file.invalid_operation then
   		po_retcode := 3;
   		po_errbuf := 'Invalid operation - '||to_char(SQLCODE) || ' ' || SQLERRM;
   		end_copy ('ERROR', NULL);

   	WHEN utl_file.write_error then
   		po_retcode := 3;
   		po_errbuf := 'Write error - '||to_char(SQLCODE) || ' ' || SQLERRM;
   		end_copy ('ERROR', NULL);

   	WHEN others THEN
   		po_retcode := 3;
   		po_errbuf := to_char(SQLCODE) || ' ' || SQLERRM;
   		end_copy ('ERROR', po_errbuf);

   END copy_percentage_burden;

   /****************************************************************************************
   * PROCEDURE                                                                             *
   *    copy_burden_pct                                                                    *
   *                                                                                       *
   * DESCRIPTION                                                                           *
   *    Copies burden percentages from source to target period                             *
   *                                                                                       *
   * INPUT PARAMETERS                                                                      *
   *    From: calendar_code, period_code, cost_mthd_code                                   *
   *    To  : calendar_code, period_code, cost_mthd_code                                   *
   *    From_Range, To_Range : from/to burden codes range                                  *
   *    Remove_or_Replace indicator: Either burden percentages in target period have to be *
   *    removed before copy starts or just replace the existing rows                       *
   *                                                                                       *
   * HISTORY                                                                               *
   *    13-Oct-1999 Uday Moogala - created.                                                *
   *    02-MARY-2003 sschinch - Bug 2934528. Bind variables fix.                           *
   ****************************************************************************************/

   PROCEDURE copy_burden_pct
   (
   pi_legal_entity_id_from          IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_from	         IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_from	            IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_from	            IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_legal_entity_id_to            IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_calendar_code_to	            IN                cm_cldr_hdr.calendar_code%TYPE,
   pi_period_code_to	               IN                cm_cldr_dtl.period_code%TYPE,
   pi_cost_type_id_to	            IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_from_range		               IN                gmf_burden_codes.burden_code%TYPE,
   pi_to_range		                  IN                gmf_burden_codes.burden_code%TYPE,
   pi_rem_repl		                  IN                NUMBER,
   pi_all_periods_from              IN                cm_cldr_dtl.period_code%TYPE,
   pi_all_periods_to                IN                cm_cldr_dtl.period_code%TYPE
	)
   IS

      /***************************
      * PL/SQL Types Definitions *
      ***************************/

      TYPE rectype_brdn_pct IS RECORD
      (
      legal_entity_id               gmf_burden_percentages.legal_entity_id%TYPE,
      period_id		               gmf_burden_percentages.period_id%TYPE,
      cost_type_id		            cm_mthd_mst.cost_type_id%TYPE,
      burden_id       	            gmf_burden_codes.burden_id%TYPE,
      burden_code     	            gmf_burden_codes.burden_code%TYPE,
      organization_id	            gmf_burden_percentages.organization_id%TYPE,
      master_organization_id	     gmf_burden_percentages.master_organization_id%TYPE,
      inventory_item_id   		      gmf_burden_percentages.inventory_item_id%TYPE,
      gl_category_id		            gmf_burden_percentages.gl_category_id%TYPE,
      cost_category_id   	         gmf_burden_percentages.cost_category_id%TYPE,
      gl_prod_line_category_id      gmf_burden_percentages.gl_prod_line_category_id%TYPE,
      gl_business_category_id   	   gmf_burden_percentages.gl_business_category_id%TYPE,
      sspl_category_id	            gmf_burden_percentages.sspl_category_id%TYPE,
      percentage   		            gmf_burden_percentages.percentage%TYPE
      );

	   TYPE curtyp_brdn_pct IS REF CURSOR;

      TYPE curtyp_periods IS REF CURSOR;

      /******************
      * Local Variables *
      ******************/

	   l_sql_stmt	                  VARCHAR2(2000);
	   l_sql_periods	               VARCHAR2(2000);
      l_period_id_to                gmf_burden_percentages.period_id%TYPE ;
      l_brdn_rows	                  NUMBER;
   	l_brdn_rows_upd	            NUMBER;
   	l_brdn_rows_ins	            NUMBER;
      l_period_id_from              gmf_burden_percentages.period_id%TYPE;
      pi_period_id_from             gmf_burden_percentages.period_id%TYPE;
      pi_period_id_to               gmf_burden_percentages.period_id%TYPE;


	   r_brdn_pct	                  rectype_brdn_pct;
	   cv_brdn_pct	                  curtyp_brdn_pct;
      cv_periods                    curtyp_periods;

     e_no_cost_rows		            EXCEPTION;

   BEGIN

	   l_sql_stmt :=  '';

	   l_sql_stmt :=  ' SELECT ' ||
		                        ' pct.legal_entity_id, ' ||
		                        ' pct.period_id, ' ||
                        		' pct.cost_type_id, ' ||
                        		' bur.burden_id, ' ||
                        		' bur.burden_code, ' ||
                        		' pct.organization_id, ' ||
                            ' pct.master_organization_id, ' ||
                        		' pct.inventory_item_id, ' ||
                        		' pct.gl_category_id, ' ||
                        		' pct.cost_category_id, ' ||
                        		' pct.gl_prod_line_category_id, ' ||
                        		' pct.gl_business_category_id, ' ||
                        		' pct.sspl_category_id, ' ||
                        		' pct.percentage ' ||
	                  ' FROM ' ||
                        		' gmf_burden_percentages pct, ' ||
                        		' gmf_burden_codes bur ' ||
	                  ' WHERE ' ||
                        		' pct.legal_entity_id	= :b_legal_entity_id AND ' ||
                        		' pct.period_id	= :b_period_id AND ' ||
                        		' pct.cost_type_id	= :b_cost_type_id AND ' ||
                        		' pct.delete_mark	= 0 AND ' ||
                        		' pct.burden_id		= bur.burden_id AND ' ||
                        		' bur.delete_mark	= 0 AND ' ||
                        		' bur.burden_code >= nvl(:b_from_brdn,bur.burden_code) AND ' ||
                        		' bur.burden_code <= nvl(:b_to_brdn,bur.burden_code) '||
                     ' ORDER BY ' ||
                        		' pct.legal_entity_id, pct.period_id, pct.cost_type_id, pct.burden_id';

      gmf_util.trace( 'Burden Percentages Sql Stmt: ' || l_sql_stmt, 1 );

      /*********************************************************************
      * Build SQL to get target periods when From/To Periods are not null. *
      *********************************************************************/

      IF (pi_period_code_to IS NOT NULL) THEN         -- copy to one period.

         l_sql_periods := 'SELECT :pi_period_id_to FROM dual ' ;

      ELSE

         l_sql_periods :=  '' ;
         l_sql_periods :=  'SELECT DISTINCT ' ||
                                    ' c3.period_id ' ||
                           'FROM ' ||
                                    'cm_cldr_mst_v c3, cm_cldr_mst_v c2, cm_cldr_mst_v c1 ' ||
                           'WHERE ' ||
                                    'c3.legal_entity_id = :pi_legal_entity_id AND ' ||
                                    'c1.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c1.period_code   = :pi_all_periods_from AND ' ||
                                    'c2.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c2.period_code   = :pi_all_periods_to   AND ' ||
                                    'c3.calendar_code = :pi_calendar_code_to AND ' ||
                                    'c3.cost_Type_id = :pi_cost_type_id_to AND ' ||
                                    'c2.legal_entity_id = c3.legal_entity_id AND ' ||
                                    'c1.legal_entity_id = c2.legal_entity_id AND ' ||
                                    'c3.start_date >=   c1.start_date AND ' ||
                                    'c3.end_date <= c2.end_date AND ' ||
                                    'c3.period_status <> ''C''';

         IF (pi_calendar_code_from = pi_calendar_code_to) THEN

            l_sql_periods := l_sql_periods || ' AND c3.period_code <> :pi_period_code_from ';

         END IF ;

	   END IF ; 	 -- To Period code check

    BEGIN
       SELECT         a.period_id
       INTO           pi_period_id_from
       FROM           cm_cldr_mst_v a
       WHERE          a.legal_entity_id = pi_legal_entity_id_from
       AND            a.calendar_code = pi_calendar_code_from
       AND            a.period_code = pi_period_code_from
       AND            a.cost_type_id = pi_cost_type_id_from;
    EXCEPTION
       WHEN OTHERS THEN
          pi_period_id_from := NULL;
    END;

    gmf_util.trace( 'Periods Query : ' || l_sql_periods, 1 );

      IF (pi_period_code_to IS NOT NULL) THEN

         BEGIN
            SELECT         a.period_id
            INTO           pi_period_id_to
            FROM           cm_cldr_mst_v a
            WHERE          a.legal_entity_id = pi_legal_entity_id_to
            AND            a.calendar_code = pi_calendar_code_to
            AND            a.period_code = pi_period_code_to
            AND            a.cost_type_id = pi_cost_type_id_to;
         EXCEPTION
            WHEN OTHERS THEN
               pi_period_id_to := NULL;
         END;


	      OPEN cv_periods FOR l_sql_periods USING pi_period_id_to;

	   ELSIF (pi_calendar_code_from = pi_calendar_code_to) THEN

	      OPEN cv_periods FOR l_sql_periods USING pi_legal_entity_id_to, pi_calendar_code_to, pi_all_periods_from, pi_calendar_code_to, pi_all_periods_to, pi_calendar_code_to, pi_cost_type_id_to, pi_period_code_from;

      ELSE

	      OPEN cv_periods FOR l_sql_periods USING pi_legal_entity_id_to, pi_calendar_code_to, pi_all_periods_from, pi_calendar_code_to, pi_all_periods_to, pi_calendar_code_to, pi_cost_type_id_to;

	   END IF;

      LOOP

	      FETCH cv_periods INTO l_period_id_to ;
	      EXIT WHEN cv_periods%NOTFOUND ;

		   IF pi_rem_repl = 1 THEN

            /*********************************************
            * deleting whole range of burden percentages *
            *********************************************/

   			delete_burden_pct
            (
            pi_legal_entity_id_to,
            l_period_id_to,
            pi_cost_type_id_to,
            pi_from_range,
            pi_to_range
   			);

		   END IF;

         /************************
         * Copy the burden costs *
         ************************/

         l_brdn_rows	:= 0;
         l_brdn_rows_upd	:= 0;
         l_brdn_rows_ins	:= 0;

		   OPEN cv_brdn_pct FOR l_sql_stmt USING pi_legal_entity_id_from, pi_period_id_from, pi_cost_type_id_from, pi_from_range, pi_to_range;
		   LOOP

		      FETCH cv_brdn_pct INTO r_brdn_pct;
		      EXIT WHEN cv_brdn_pct%NOTFOUND;
            gmf_util.log;
		      gmf_util.msg_log('GMF_CPPB_PERIOD_BRDN', r_brdn_pct.burden_code, to_char(l_period_id_to)) ;
            gmf_util.trace( 'Burden : ' || r_brdn_pct.burden_code || ' Prd Id: ' || TO_CHAR(r_brdn_pct.period_id) || ' Cost Type: ' || TO_CHAR(r_brdn_pct.cost_type_id) ||
			' Organization Id: ' || nvl(TO_CHAR(r_brdn_pct.organization_id),'') || ' Item Id: ' || nvl(TO_CHAR(r_brdn_pct.inventory_item_id),'') || ' GL Class: ' ||
			nvl(r_brdn_pct.gl_category_id,'') || ' ItemCC: ' || nvl(r_brdn_pct.cost_category_id,''), 3 );
            l_brdn_rows := l_brdn_rows + 1;

            /*******************
            * Try update first *
            *******************/

		      <<insert_or_update_bur>>
		      DECLARE
			      e_insert_row_b	EXCEPTION;
		      BEGIN
			      IF( pi_rem_repl = 1 ) THEN
				      RAISE e_insert_row_b;
			      END IF;

            UPDATE        gmf_burden_percentages
			      SET           burden_percentage_id 	= GMF_BURDEN_PERCENTAGE_ID_S.NEXTVAL,
				                  percentage 		= r_brdn_pct.percentage,
				                  delete_mark 		= 0,
                  				last_updated_by		= g_user_id,
                  				last_update_login	= g_login_id,
                  				last_update_date	= SYSDATE
		         WHERE
                  				legal_entity_id = pi_legal_entity_id_to AND
                  				period_id		= l_period_id_to AND
                  				cost_type_id		= pi_cost_type_id_to AND
                  				burden_id		= r_brdn_pct.burden_id AND
                  				nvl(organization_id,-1)	= nvl(r_brdn_pct.organization_id,-1) AND
                          nvl(master_organization_id,-1)	= nvl(r_brdn_pct.master_organization_id,-1) AND
                  				nvl(inventory_item_id,-1) 	= nvl(r_brdn_pct.inventory_item_id,-1) AND
                  				nvl(gl_category_id,-1) 	= nvl(r_brdn_pct.gl_category_id,-1) AND
                  				nvl(cost_category_id,-1) 	= nvl(r_brdn_pct.cost_category_id,-1) AND
                  				nvl(gl_prod_line_category_id,-1) 	= nvl(r_brdn_pct.gl_prod_line_category_id,-1) AND
                  				nvl(gl_business_category_id,-1) = nvl(r_brdn_pct.gl_business_category_id,-1) AND
                  				nvl(sspl_category_id,-1) 	= nvl(r_brdn_pct.sspl_category_id,-1);

               /**********************************
               * If update fails then try insert *
               **********************************/
      			IF( SQL%ROWCOUNT <= 0 ) THEN
				      RAISE e_insert_row_b;
			      END IF;

			      l_brdn_rows_upd	:= l_brdn_rows_upd + 1;

		      EXCEPTION
			      WHEN e_insert_row_b THEN

                  INSERT INTO    gmf_burden_percentages
                  (
                  burden_percentage_id,
                  legal_entity_id,
                  period_id,
                  cost_type_id,
                  burden_id,
                  organization_id,
                  master_organization_id,
                  inventory_item_id,
                  gl_category_id,
                  cost_category_id,
                  gl_prod_line_category_id,
                  gl_business_category_id,
                  sspl_category_id,
                  percentage,
                  delete_mark,
                  created_by,
                  creation_date,
                  last_updated_by,
                  last_update_date,
                  last_update_login
				      )
				      VALUES
                  (
                  GMF_BURDEN_PERCENTAGE_ID_S.NEXTVAL,
                  pi_legal_entity_id_to,
                  l_period_id_to,
                  pi_cost_type_id_to,
                  r_brdn_pct.burden_id,
                  r_brdn_pct.organization_id,
                  r_brdn_pct.master_organization_id,
                  r_brdn_pct.inventory_item_id,
                  r_brdn_pct.gl_category_id,
                  r_brdn_pct.cost_category_id,
                  r_brdn_pct.gl_prod_line_category_id,
                  r_brdn_pct.gl_business_category_id,
                  r_brdn_pct.sspl_category_id,
                  r_brdn_pct.percentage,
                  0,			-- delete_mark
                  g_user_id,		-- created_by
                  SYSDATE,		-- creation_date
                  g_user_id,		-- last_updated_by
                  SYSDATE,		-- last_update_date
                  g_login_id		-- last_update_login
				      );

				      l_brdn_rows_ins := l_brdn_rows_ins + 1;
            END insert_or_update_bur;

	      END LOOP;	-- End loop of Source Burden Percentage.

	      CLOSE cv_brdn_pct;

	      IF( l_brdn_rows > 0 ) THEN

		      gmf_util.msg_log( 'GMF_CP_ROWS_SELECTED', TO_CHAR(l_brdn_rows) );
		      gmf_util.msg_log( 'GMF_CP_ROWS_UPDINS',TO_CHAR(l_brdn_rows_upd), TO_CHAR(l_brdn_rows_ins));

         ELSE

		      gmf_util.msg_log( 'GMF_CP_NO_ROWS' );

	      END IF;

      END LOOP ;		-- periods loop

      CLOSE cv_periods;

   END copy_burden_pct;

   /**************************************************************
   * PROCEDURE                                                   *
   *    delete_burden_pct                                        *
   *                                                             *
   * DESCRIPTION                                                 *
   *    Deletes the burden percentages for the parameters passed *
   *                                                             *
   * INPUT PARAMETERS                                            *
   *    calendar, period, cost_mthd, burden_codes range          *
   *                                                             *
   * HISTORY                                                     *
   *    15-Feb-2001 Uday Moogala Seshadri                        *
   **************************************************************/

   PROCEDURE delete_burden_pct
   (
   pi_legal_entity_id            IN          gmf_burden_percentages.legal_entity_id%TYPE,
   pi_period_id                  IN          gmf_burden_percentages.period_id%TYPE,
   pi_cost_type_id               IN          cm_mthd_mst.cost_type_id%TYPE,
   pi_from_range		            IN          gmf_burden_codes.burden_code%TYPE,
   pi_to_range		               IN          gmf_burden_codes.burden_code%TYPE
	)
   IS

      /******************
      * Local Variables *
      ******************/

	   l_del_stmt	VARCHAR2(1500);
	   l_sub_qry	VARCHAR2(500);

   BEGIN

	   l_del_stmt	:= '';
	   l_sub_qry	:= '';

	   l_del_stmt :=  ' DELETE FROM gmf_burden_percentages pct ' ||
	                  ' WHERE ' ||
                        		' pct.legal_entity_id	= :b_legal_entity_id AND ' ||
                        		' pct.period_id	= :b_period_id AND ' ||
                        		' pct.cost_type_id	= :b_cost_type_id AND ' ||
                        		' pct.burden_id IN ( ';

	   l_sub_qry :=   ' SELECT ' ||
			                     ' bur.burden_id ' ||
		               ' FROM ' ||
			                     ' gmf_burden_codes bur ' ||
		               ' WHERE ' ||
                     			' bur.delete_mark = 0 AND ' ||
                     			' bur.burden_code >= nvl(:b_burden_code_from,bur.burden_code) AND ' ||
                     			' bur.burden_code <= nvl(:b_burden_code_to,bur.burden_code) ' ;

	   l_del_stmt := l_del_stmt || l_sub_qry || ' ) ' ;

	   gmf_util.trace( ' Burden Del Stmt: ' || l_del_stmt, 1 );

	   EXECUTE IMMEDIATE l_del_stmt USING pi_legal_entity_id, pi_period_id, pi_cost_type_id, pi_from_range, pi_to_range;

	   gmf_util.trace( SQL%ROWCOUNT || ' Rows deleted', 1 );

   END delete_burden_pct;

   /************************************************************************************
   * PROCEDURE                                                                         *
   *    end_copy                                                                       *
   *                                                                                   *
   * DESCRIPTION                                                                       *
   *    Sets the concurrent manager completion status                                  *
   *                                                                                   *
   * INPUT PARAMETERS                                                                  *
   *    pi_errstat - Completion status, must be one of 'NORMAL', 'WARNING', OR 'ERROR' *
   *    pi_errmsg - Completion message to be passed back                               *
   *                                                                                   *
   * HISTORY                                                                           *
   *    13-Oct-1999 Rajesh Seshadri                                                    *
   ************************************************************************************/

   PROCEDURE end_copy
   (
	pi_errstat                 IN                VARCHAR2,
	pi_errmsg                  IN                VARCHAR2
	)
   IS

      /******************
      * Local Variables *
      ******************/

	   l_retval BOOLEAN;

   BEGIN

	   l_retval := fnd_concurrent.set_completion_status(pi_errstat,pi_errmsg);

   END end_copy;

   /*******************************************************************************
   * FUNCTION                                                                     *
   *    do_pct_exist                                                              *
   *                                                                              *
   * DESCRIPTION                                                                  *
   *    Verifies if there exists any burden percentages for the parameters passed *
   *                                                                              *
   * INPUT PARAMETERS                                                             *
   *    pi_calendar_code        Cost Calendar                                     *
   *    pi_period_code          Cost Period                                       *
   *    pi_cost_mthd_code       Cost Method                                       *
   *    pi_burden_code_from     Burden Code from                                  *
   *    pi_burden_code_to       Burden Code to                                    *
   *    Verifies if any costs exists for the above parameters                     *
   *                                                                              *
   * HISTORY                                                                      *
   *    20-Feb-2001 Uday Moogala                                                  *
   *******************************************************************************/

   FUNCTION do_pct_exist
   (
   pi_legal_entity_id         IN                gmf_burden_percentages.legal_entity_id%TYPE,
   pi_period_id               IN                gmf_burden_percentages.period_id%TYPE,
	pi_cost_type_id            IN                cm_mthd_mst.cost_type_id%TYPE,
   pi_burden_code_from        IN                gmf_burden_codes.burden_code%TYPE,
   pi_burden_code_to          IN                gmf_burden_codes.burden_code%TYPE
   )
   RETURN NUMBER
   IS

      /**********
      * Cursors *
      **********/

      CURSOR cur_num_pct_rows
      (
      p_legal_entity_id       IN                gmf_burden_percentages.legal_entity_id%TYPE,
      p_period_id             IN                gmf_burden_percentages.period_id%TYPE,
      p_burden_code_from      IN                gmf_burden_codes.burden_code%TYPE,
      p_burden_code_to        IN                gmf_burden_codes.burden_code%TYPE
      )
	   IS
      SELECT                  COUNT(1)
      FROM                    gmf_burden_percentages pct,
                              gmf_burden_codes bur
      WHERE                   pct.legal_entity_id   = p_legal_entity_id
      AND                     pct.period_id       = p_period_id
      AND                     pct.delete_mark       = 0
      AND                     pct.burden_id         = bur.burden_id
      AND                     bur.delete_mark       = 0
      AND                     bur.burden_code       >= nvl(p_burden_code_from,bur.burden_code)
      AND                     bur.burden_code       <= nvl(p_burden_code_to,bur.burden_code);

      /******************
      * Local Variables *
      ******************/

      l_num_rows NUMBER := 0;

   BEGIN

      OPEN cur_num_pct_rows( pi_legal_entity_id, pi_period_id, pi_burden_code_from, pi_burden_code_to );
      FETCH cur_num_pct_rows INTO l_num_rows;
      CLOSE cur_num_pct_rows;

      RETURN l_num_rows;
   END do_pct_exist;

END gmf_copy_percentage_burden;

/
