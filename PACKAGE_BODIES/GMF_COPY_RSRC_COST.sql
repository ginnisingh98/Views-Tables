--------------------------------------------------------
--  DDL for Package Body GMF_COPY_RSRC_COST
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_COPY_RSRC_COST" AS
/* $Header: gmfcprcb.pls 120.6 2006/04/13 02:24:25 jboppana noship $ */

   PROCEDURE end_copy
   (
	pi_errstat	      IN          VARCHAR2,
	pi_errmsg	      IN          VARCHAR2
	);

   /*****************************************************************************************************************
   * PROCEDURE                                                                                                      *
   *    copy_rsrc_cost                                                                                              *
   *                                                                                                                *
   * DESCRIPTION                                                                                                    *
   *    Copy Resource Costs Procedure                                                                               *
   *    Copies costs from the one set of orgn/cost calendar/period/cost method                                      *
   *    to another for the resource class specified on the form.                                                    *
   *                                                                                                                *
   * INPUT PARAMETERS                                                                                               *
   *    From and To orgn/calendar/period/cost method                                                                *
   *    pi_resource_class Costs for all Resources that are belong to this                                           *
   *    resouce class will be copied to the target period                                                           *
   *                                                                                                                *
   * OUTPUT PARAMETERS                                                                                              *
   *    po_errbuf      Completion message to the Concurrent Manager                                                 *
   *    po_retcode     Return code to the Concurrent Manager                                                        *
   *                                                                                                                *
   * HISTORY                                                                                                        *
   *    11-Oct-1999 Rajesh Seshadri                                                                                 *
   *    21-Nov-2000 Uday Moogala - Bug# 1419482 Copy Cost Enhancement.                                              *
   *       1. Copy to all periods option :                                                                          *
   *          Copy item/burden cost from one costing period to all the subsequent                                   *
   *          open/frozen costing periods in the same calendar or                                                   *
   *          to all the open/frozen periods if it is a different calendar.                                         *
   *       For more details refer to DLD : GMF_CC_11i+_dld.rtf                                                      *
   *    30-OCT-2002    RajaSekhar    Bug#2641405 Added NOCOPY hint.                                                 *
   *    09-Jan-2003    Anoop         Bug#3345313 Added the if condition to check the if resource class is not null. *
   *****************************************************************************************************************/

   PROCEDURE copy_rsrc_cost
   (
	po_errbuf		               OUT NOCOPY  VARCHAR2,
	po_retcode		               OUT NOCOPY  VARCHAR2,
   pi_legal_entity_id_from	   IN             cm_rsrc_dtl.legal_entity_id%TYPE,
	pi_organization_id_from	   IN             cm_rsrc_dtl.organization_id%TYPE,
	pi_calendar_code_from	   IN             cm_rsrc_dtl.calendar_code%TYPE,
	pi_period_code_from	      IN             cm_rsrc_dtl.period_code%TYPE,
	pi_cost_type_id_from	      IN             cm_rsrc_dtl.cost_type_id%TYPE,
   pi_legal_entity_id_to	   IN             cm_rsrc_dtl.legal_entity_id%TYPE,
	pi_organization_id_to		IN             cm_rsrc_dtl.organization_id%TYPE,
	pi_calendar_code_to	      IN             cm_rsrc_dtl.calendar_code%TYPE,
	pi_period_code_to	         IN             cm_rsrc_dtl.period_code%TYPE,
	pi_cost_type_id_to	      IN             cm_rsrc_dtl.cost_type_id%TYPE,
	pi_resource_class	         IN             cr_rsrc_mst.resource_class%TYPE,
   pi_all_periods_from        IN             cm_cmpt_dtl.period_code%TYPE,
   pi_all_periods_to          IN             cm_cmpt_dtl.period_code%TYPE,
   pi_all_organization_flag   IN             NUMBER
	)
   IS

      /*************************
      * PL/SQL Typ Definitions *
      *************************/

      TYPE rectyp_rsrc_dtl IS RECORD   (
		                                 resources	         cm_rsrc_dtl.resources%TYPE,
		                                 nominal_cost	      cm_rsrc_dtl.nominal_cost%TYPE,
		                                 usage_uom	         cm_rsrc_dtl.usage_uom%TYPE
	                                    );

	   TYPE curtyp_rsrc IS REF CURSOR ;

	   TYPE curtyp_orgn IS REF CURSOR ;

	   TYPE curtyp_periods IS REF CURSOR ;

      /******************
      * Local Variables *
      ******************/

      rec_rsrc_dtl	         rectyp_rsrc_dtl ;
	   cv_rsrc_dtl	            curtyp_rsrc ;
	   cv_orgn		            curtyp_orgn ;
	   cv_periods	            curtyp_periods ;


	   l_sql_rsrc	            VARCHAR2(2000) ;
	   l_sql_orgn	            VARCHAR2(2000) ;
	   l_sql_periods	         VARCHAR2(2000) ;
      l_from_range	         cr_rsrc_mst.resources%TYPE ;
	   l_to_range	            cr_rsrc_mst.resources%TYPE ;
	   l_organization_id_to	   cm_rsrc_dtl.organization_id%TYPE;
      pi_period_id_to         cm_rsrc_dtl.period_id%TYPE ;
      l_period_id_from        cm_rsrc_dtl.period_id%TYPE ;
	   l_period_id_to          cm_rsrc_dtl.period_id%TYPE ;
      l_legal_entity_id_to    cm_rsrc_dtl.legal_entity_id%TYPE;
      l_cost_Type_id_to       cm_rsrc_dtl.cost_Type_id%TYPE;
      l_user_id               NUMBER := FND_GLOBAL.USER_ID;
	   l_num_src_rows          NUMBER;	-- num cost rows in source period
	   l_ins_rows              NUMBER;	-- num rows inserted
	   l_upd_rows              NUMBER;	-- num rows updated
	   l_routine	            VARCHAR2(41) := 'copy_rsrc_cost' ;
	   e_no_cost_rows	         EXCEPTION;

   BEGIN

      /****************************************************
      * Uncomment the call below to write to a local FILE *
      ****************************************************/

      ---FND_FILE.PUT_NAMES('gmfcprc.log','gmfcprc.out','/sqlcom/log/dom1151');


	   gmf_util.msg_log( 'GMF_CPRC_START' );
	   gmf_util.msg_log( 'GMF_CPRC_SRCPARAM', nvl(TO_CHAR(pi_organization_id_from), ' '), nvl(pi_calendar_code_from, ' '), nvl(pi_period_code_from, ' '), nvl(TO_CHAR(pi_cost_type_id_from), ' '), nvl(pi_resource_class, ' '));
	   gmf_util.msg_log( 'GMF_CPRC_TGTPARAM', nvl(TO_CHAR(pi_organization_id_to), ' '), nvl(pi_calendar_code_to, ' '), nvl(pi_period_code_to, ' '), nvl(TO_CHAR(pi_cost_type_id_to), ' '));

      IF ((pi_period_code_to IS NULL) AND ((pi_all_periods_from IS NOT NULL) OR (pi_all_periods_to IS NOT NULL))) THEN
         gmf_util.msg_log('GMF_CPRC_PERIODS_RANGE', nvl(pi_all_periods_from, ' '), nvl(pi_all_periods_to, ' '), nvl(pi_calendar_code_to, ' ')) ;
      END IF ;

	   l_ins_rows := 0;
	   l_upd_rows := 0;

      BEGIN
         SELECT         period_id
         INTO           l_period_id_from
         FROM           cm_cldr_mst_v
         WHERE          legal_entity_id = pi_legal_entity_id_from
         AND            calendar_code = pi_calendar_code_from
         AND            period_code = pi_period_code_from
         AND            cost_type_id = pi_cost_type_id_from;
      EXCEPTION
         WHEN OTHERS THEN
            l_period_id_from := NULL;
      END;

      IF (l_period_id_from IS NULL) THEN
		   gmf_util.msg_log ('GMF_CP_NO_ROWS');
		   RAISE e_no_cost_rows;
      END IF;
      IF (pi_period_code_to IS NOT NULL) THEN
         BEGIN
            SELECT         period_id
            INTO           pi_period_id_to
            FROM           cm_cldr_mst_v
            WHERE          legal_entity_id = pi_legal_entity_id_to
            AND            calendar_code = pi_calendar_code_to
            AND            period_code = pi_period_code_to
            AND            cost_type_id = pi_cost_type_id_to;
         EXCEPTION
            WHEN OTHERS THEN
               pi_period_id_to := NULL;
         END;

         IF (pi_period_id_to IS NULL) THEN
            gmf_util.msg_log ('GMF_CP_NO_ROWS');
            RAISE e_no_cost_rows;
         END IF;
        END IF;

      --jboppana has to uncomment after testing
	   --l_num_src_rows := do_costs_exist( pi_organization_id_from, l_period_id_from, pi_resource_class);

	   IF (l_num_src_rows <= 0) THEN
		   gmf_util.msg_log ('GMF_CP_NO_ROWS');
		   RAISE e_no_cost_rows;
	   END IF;

      l_sql_rsrc :=  '' ;
	   l_sql_rsrc :=  ' SELECT ' ||
		                        'd.resources, ' ||
                              'd.nominal_cost, ' ||
                              'd.usage_uom ' ||
	                  ' FROM ' ||
		                        'cm_rsrc_dtl d, ' ||
		                        'cr_rsrc_mst m ' ||
	                  ' WHERE ' ||
                              'd.legal_entity_id = :b_legal_entity_id AND '||
                        		'nvl(d.organization_id,0) = nvl(:b_organization_id,0) AND ' ||
                        		'd.period_id = :b_period_id AND ' ||
                        		'd.delete_mark = 0 AND ' ||
                        		'd.resources = m.resources AND ' ||
                        		'm.delete_mark = 0 ' ;


	   IF (pi_resource_class IS NOT NULL)  THEN

		   l_sql_rsrc := l_sql_rsrc || ' AND m.resource_class = nvl(:b_resource_class, m.resources) '  ;

      END IF 	;

	   l_sql_rsrc := l_sql_rsrc || ' ORDER BY ' || ' d.resources' ;

	   gmf_util.trace( 'Resource Query : ' || l_sql_rsrc, 1 ) ;

      /**************************************************************************
      * Build SQL to get target Orgs when from/to orgns are not null.           *
      * IF (pi_all_orgn_from IS NOT NULL) AND (pi_all_orgn_to IS NOT NULL) THEN *
      **************************************************************************/

	   IF (pi_all_organization_flag = 0) THEN

         l_sql_orgn :=  '' ;
		   l_sql_orgn :=  'SELECT :pi_organization_id_to FROM  dual ' ;
      ELSE
         l_sql_orgn := '' ;
          l_sql_orgn :=
   		'SELECT ' ||
   			'hr.organization_id ' ||
   		'FROM ' ||
   			'hr_organization_information hr , mtl_parameters mp ' ||
   		'WHERE ' ||
   			'hr.org_information2   = :pi_legal_entity_id_to '||
             ' and hr.org_information_context = ''Accounting Information'' '||
             ' and hr.organization_id = mp.organization_id '||
             ' and mp.process_enabled_flag = ''Y'' ' ;

         IF ( (pi_calendar_code_from = pi_calendar_code_to) AND
		     (pi_period_code_to IS NOT NULL) AND
		     (l_period_id_from = pi_period_id_to)
		      ) THEN
   		    l_sql_orgn := l_sql_orgn  ||' AND nvl(organization_id,0) <> nvl(:pi_organization_id_from,0) ' ;
          END IF ;
         l_sql_orgn := l_sql_orgn || ' ORDER BY organization_id ' ;
         END IF ;



      IF (pi_period_code_to IS NOT NULL) THEN
         l_sql_periods :=  'SELECT :pi_legal_entity_id_to, :pi_period_id_to FROM dual ' ;
        ELSE
         l_sql_periods :=  '' ;
         l_sql_periods :=  'SELECT DISTINCT ' ||
                                    'c3.legal_entity_id, c3.period_id ' ||
                           'FROM ' ||
                                    'cm_cldr_mst_v c3, cm_cldr_mst_v c2, cm_cldr_mst_v c1 ' ||
                           'WHERE ' ||
                                    'c3.legal_entity_id = :pi_legal_entity_id_to AND '||
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

	   END IF;

   	gmf_util.trace( 'Periods Query : ' || l_sql_periods, 1 ) ;
   	gmf_util.trace( 'Orgn Query : ' || l_sql_orgn, 1 ) ;

      /*********************************************************************************
      * Do not pass the l_from_range and l_to_range if resource class is not specified *
      *********************************************************************************/
      IF pi_resource_class is not null then

         OPEN cv_rsrc_dtl FOR l_sql_rsrc USING pi_legal_entity_id_from,pi_organization_id_from, l_period_id_from, pi_resource_class;

      ELSE

         OPEN cv_rsrc_dtl FOR l_sql_rsrc USING pi_legal_entity_id_from,pi_organization_id_from, l_period_id_from;

      END IF;

   	LOOP

         FETCH cv_rsrc_dtl INTO rec_rsrc_dtl ;
   		EXIT WHEN cv_rsrc_dtl%NOTFOUND ;

         IF (pi_period_code_to IS NOT NULL) THEN
           OPEN cv_periods FOR l_sql_periods USING pi_legal_entity_id_to, pi_period_id_to;
   	   ELSIF (pi_calendar_code_from = pi_calendar_code_to) THEN
   	      OPEN cv_periods FOR l_sql_periods USING pi_legal_entity_id_to, pi_calendar_code_to, pi_all_periods_from, pi_calendar_code_to, pi_all_periods_to, pi_calendar_code_to, pi_cost_type_id_to, pi_period_code_from;
         ELSE
   	      OPEN cv_periods FOR l_sql_periods USING pi_legal_entity_id_to, pi_calendar_code_to, pi_all_periods_from, pi_calendar_code_to, pi_all_periods_to, pi_calendar_code_to, pi_cost_type_id_to;
   	   END IF;

   		LOOP

   			FETCH cv_periods INTO l_legal_entity_id_to, l_period_id_to;
   			EXIT WHEN cv_periods%NOTFOUND ;

            IF (pi_all_organization_flag = 0) THEN
                 OPEN cv_orgn FOR l_sql_orgn USING pi_organization_id_to;
	          ELSIF ((pi_calendar_code_from = pi_calendar_code_to) AND
		                    (pi_period_id_to IS NOT NULL) AND
		                    (l_period_id_from = pi_period_id_to)) THEN
	                OPEN cv_orgn FOR l_sql_orgn
	                     USING  pi_legal_entity_id_to,
	                     pi_organization_id_from;
	           ELSE
	             OPEN cv_orgn FOR l_sql_orgn
	                   USING  pi_legal_entity_id_to;
              END IF;
            LOOP

   				FETCH cv_orgn INTO l_organization_id_to ;
   				EXIT WHEN cv_orgn%NOTFOUND ;

   				gmf_util.trace( 'Values : ' || rec_rsrc_dtl.resources || ' - ' || rec_rsrc_dtl.usage_uom || ' - ' || to_char(rec_rsrc_dtl.nominal_cost), 1 );
               gmf_util.msg_log('GMF_CPRC_ORGPRD', nvl(TO_CHAR(l_organization_id_to), ' '), nvl(TO_CHAR(l_period_id_to),' '));

   				UPDATE      cm_rsrc_dtl
   				SET         usage_uom         = rec_rsrc_dtl.usage_uom,
   					         nominal_cost     = rec_rsrc_dtl.nominal_cost,
   					         rollover_ind     = 0,	----unset the rollover_ind in target period
   					         last_update_date = SYSDATE,
   					         last_updated_by  = l_user_id,
   					         trans_cnt        = 1,
   					         delete_mark      = 0
   				WHERE       legal_entity_id = l_legal_entity_id_to
               AND         nvl(organization_id,0) = nvl(l_organization_id_to,0)
               AND         period_id = l_period_id_to
               AND         resources = rec_rsrc_dtl.resources;

   				IF SQL%ROWCOUNT > 0 THEN

                  l_upd_rows := l_upd_rows + SQL%ROWCOUNT;
                  gmf_util.trace( 'Updated ' || TO_CHAR(SQL%ROWCOUNT) || ' rows', 1 );

               ELSE

   			      INSERT INTO    cm_rsrc_dtl
                  (
                  legal_entity_id,
                  organization_id,
                  resources,
                  period_id,
                  cost_type_id,
                  usage_uom,
                  nominal_cost,
                  rollover_ind,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  trans_cnt,
                  delete_mark
   					)
   					VALUES
                  (
                  l_legal_entity_id_to,
                  l_organization_id_to,
                  rec_rsrc_dtl.resources,
                  l_period_id_to,
                  pi_cost_type_id_to,
                  rec_rsrc_dtl.usage_uom,
                  rec_rsrc_dtl.nominal_cost,
                  0,	----unset the rollover_ind in the target period
                  SYSDATE,
                  l_user_id,
                  SYSDATE,
                  l_user_id,
                  1,
                  0
   					);

   					l_ins_rows := l_ins_rows + SQL%ROWCOUNT;
                  gmf_util.trace( 'Inserted ' || TO_CHAR(SQL%ROWCOUNT) || ' rows', 1 );

               END IF;
   	      END LOOP;	-- end of cursor for loop for Orgs
   		END LOOP;	-- end of cursor for loop for periods
   	END LOOP;	-- end of cursor for loop for resources

   	gmf_util.msg_log( 'GMF_CP_ROWS_SELECTED', TO_CHAR(l_ins_rows + l_upd_rows) );
   	gmf_util.msg_log( 'GMF_CP_ROWS_UPDINS', TO_CHAR(l_upd_rows), TO_CHAR(l_ins_rows) );
      gmf_util.log;
   	gmf_util.msg_log( 'GMF_CPRC_END' );

      po_retcode := 0;
   	po_errbuf := NULL;
   	end_copy('NORMAL', NULL);
   	COMMIT;

   EXCEPTION
	   WHEN e_no_cost_rows THEN

		   po_retcode := 0;
		   po_errbuf := NULL;
		   end_copy( 'NORMAL', NULL );

	   WHEN utl_file.invalid_path THEN

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
   		end_copy ('ERROR', NULL);
   END copy_rsrc_cost;

   /**************************************************************************************
   * FUNCTION                                                                            *
   *    do_costs_exist                                                                   *
   *                                                                                     *
   *   DESCRIPTION                                                                       *
   *     Verifies if there exists any resource costs for the parameters passed           *
   *                                                                                     *
   *   INPUT PARAMETERS
   *    pi_legal_entity_id   Legal Entity                                                              *
   *    pi_organization_id   Organization                                                *
   *    pi_calendar_code     Cost Calendar                                               *
   *    pi_period_code       Cost Period                                                 *
   *    pi_cost_type_id      Cost Method                                                 *
   *    pi_resource_class    Resource Class                                              *
   *                                                                                     *
   *   HISTORY                                                                           *
   *     11-Oct-1999 Rajesh Seshadri                                                     *
   *     09-Jan-2004 Anoop Baddam BUG#3345313.                                           *
   *     Modified the cursor cur_num_cost_rows.                                          *
   *     Added the condition "p_resource_class IS NULL" to the where clause              *
   *     that checks if there are any costs even if the resource class is not specified. *
   **************************************************************************************/

   FUNCTION do_costs_exist
   (
   pi_legal_entity_id      IN             cm_rsrc_dtl.legal_entity_id%TYPE,
	pi_organization_id	   IN             cm_rsrc_dtl.organization_id%TYPE,
	pi_period_id		      IN             cm_rsrc_dtl.period_id%TYPE,
	pi_resource_class	      IN             cr_rsrc_mst.resource_class%TYPE
	)
   RETURN NUMBER
   IS
	 CURSOR cur_num_cost_rows
      (
      p_legal_entity_id          IN       cm_rsrc_dtl.legal_entity_id%TYPE,
		p_organization_id		      IN       cm_rsrc_dtl.organization_id%TYPE,
		p_period_id		            IN       cm_rsrc_dtl.period_id%TYPE,
		p_resource_class	         IN       cr_rsrc_mst.resource_class%TYPE
		)
      IS
		SELECT      COUNT(1)
		FROM        cm_rsrc_dtl d,
			         cr_rsrc_mst m
		WHERE       d.legal_entity_id = p_legal_entity_id
      AND         nvl(d.organization_id,0)	= nvl(p_organization_id,0)
      AND         d.period_id = p_period_id
      AND         d.delete_mark = 0
      AND         d.resources	= m.resources
      AND         (
                  p_resource_class IS NULL
                  OR m.resource_class	= p_resource_class
                  )
      AND         m.delete_mark		= 0;

	   l_num_rows NUMBER := 0;
	   l_routine	VARCHAR2(41) := 'do_costs_exist' ;

   BEGIN

      OPEN cur_num_cost_rows( pi_legal_entity_id,pi_organization_id, pi_period_id, pi_resource_class );
      FETCH cur_num_cost_rows INTO l_num_rows;
      CLOSE cur_num_cost_rows;

	   RETURN l_num_rows;

   END do_costs_exist;

/**************************************************************************************
   * FUNCTION                                                                            *
   *    do_costs_exist                                                                  *
   *                                                                                     *
   *   DESCRIPTION                                                                       *
   *     Verifies if there exists any resource costs for the parameters passed           *
   *                                                                                     *
   *   INPUT PARAMETERS
   *    pi_legal_entity_id   Legal Entity                                                              *
   *                                             *
   *    pi_period_id      Cost Period                                                 *
   *    pi_cost_type_id      Cost Method                                                 *
   *    pi_resource_class    Resource Class                                              *
   *                                                                                     *
   *
   **************************************************************************************/

   FUNCTION do_costs_exist
   (
   pi_legal_entity_id      IN             cm_rsrc_dtl.legal_entity_id%TYPE,
   pi_period_id		      IN             cm_rsrc_dtl.period_id%TYPE,
	pi_resource_class	      IN             cr_rsrc_mst.resource_class%TYPE
	)
   RETURN NUMBER
   IS
	 CURSOR cur_num_cost_rows
      (
      p_legal_entity_id          IN       cm_rsrc_dtl.legal_entity_id%TYPE,
      p_period_id		            IN       cm_rsrc_dtl.period_id%TYPE,
		p_resource_class	         IN       cr_rsrc_mst.resource_class%TYPE
		)
      IS
		SELECT      COUNT(1)
		FROM        cm_rsrc_dtl d,
			         cr_rsrc_mst m
		WHERE       d.legal_entity_id = p_legal_entity_id
      AND         d.organization_id IN (SELECT a.organization_id FROM  hr_organization_information a, mtl_parameters b
  					   		                 where a.organization_id = b.organization_id
							                      and b.process_enabled_flag = 'Y' and
							                          a.org_information2 = p_legal_entity_id
                                            and a.org_information_context = 'Accounting Information' )

      AND         d.period_id = p_period_id
      AND         d.delete_mark = 0
      AND         d.resources	= m.resources
      AND         (
                  p_resource_class IS NULL
                  OR m.resource_class	= p_resource_class
                  )
      AND         m.delete_mark		= 0;

	   l_num_rows NUMBER := 0;
	   l_routine	VARCHAR2(41) := 'do_costs_exist' ;

   BEGIN

      OPEN cur_num_cost_rows( pi_legal_entity_id, pi_period_id, pi_resource_class );
      FETCH cur_num_cost_rows INTO l_num_rows;
      CLOSE cur_num_cost_rows;

	   RETURN l_num_rows;

   END do_costs_exist;





   /*****************************************************************************
   * PROCEDURE                                                                  *
   *     end_copy                                                               *
   *                                                                            *
   *   DESCRIPTION                                                              *
   *     Sets the concurrent manager completion status                          *
   *                                                                            *
   *   INPUT PARAMETERS                                                         *
   *     pi_errstat - Completion status, must be one of 'NORMAL', 'WARNING', or *
   *    'ERROR'                                                                 *
   *     pi_errmsg - Completion message to be passed back                       *
   *                                                                            *
   *   HISTORY                                                                  *
   *     11-Oct-1999 Rajesh Seshadri                                            *
   *                                                                            *
   *****************************************************************************/

   PROCEDURE end_copy
   (
	pi_errstat        IN          VARCHAR2,
	pi_errmsg         IN          VARCHAR2
	)
   IS
	   l_retval BOOLEAN;
   BEGIN

      l_retval := fnd_concurrent.set_completion_status(pi_errstat,pi_errmsg);

   END end_copy;

END gmf_copy_rsrc_cost;

/
