--------------------------------------------------------
--  DDL for Package Body XXAH_MGT_REP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XXAH_MGT_REP_PKG" 
AS
/* ***************************************************************************
 * PACKAGE BODY  XXAH_MGT_REP_MGT
 *
 * VERSION       1.2 - 21-07-2010
 *
 * Reporting package for projects or sourcing negotions.
 *
 * Version History:
 * Date       Editor             Change
 * ---------- ------------------ -----------------------
 * ??-??-???? Patrick Timmermans Initial creation.
 * 13-07-2009 Nico Klaver        Added header lines.
 * 21-07-2010 Kevin Bouwmeester  Reformated code.
 * ***************************************************************************/
  -- return codes for concurent request
  gc_retcode_succes  CONSTANT NUMBER := 0;
  gc_retcode_warning CONSTANT NUMBER := 1;
  gc_retcode_error   CONSTANT NUMBER := 2;

  /* ***************************************************************************
   * PROCEDURE   : negotiotion_reporting
   *
   * CALLED BY   : concurrent program
   *
   * DESCRIPTION :
   * Print comma seperated data from projects that have template_flag = 'N'
   * Data printed is: Project Number, Project Name, Created By User Name,
   * Project start date, project end date, Completion Percentage.
   * ***************************************************************************/
  PROCEDURE project_reporting
  ( x_retbuf  OUT VARCHAR2
  , x_retcode OUT NUMBER)
  IS
    CURSOR c_proj
    IS
    SELECT *
    FROM   (SELECT DISTINCT
              ppa.segment1 ngs
            , ppa.name project_name
            , pa_project_parties_utils.get_current_proj_manager_name
              ( ppa.project_id ) created_by
            , decode( ppa.actual_start_date
                    , ''
                    , decode( ppa.scheduled_start_date
                            , ''
                            , ppa.target_start_date
                            , ppa.scheduled_start_date)
                    , ppa.actual_start_date
                    ) start_date
            , decode(ppa.actual_finish_date
                    , ''
                    , decode( ppa.scheduled_finish_date
                            , ''
                            , ppa.target_finish_date
                            , ppa.scheduled_finish_date)
                    , ppa.actual_finish_date
                    ) end_date
            ,(
              SELECT nvl(MAX(psv.completed_percentage), 0)
              FROM   pa_structure_versions_v psv
              WHERE  psv.project_id = ppa.project_id
              AND    psv.structure_type = 'WORKPLAN'
              AND    psv.structure_version_number
                     IN
                     (
                      SELECT MAX(psv2.structure_version_number)
                      FROM   pa_structure_versions_v psv2
                      WHERE  psv2.project_id = psv.project_id
                      AND    psv.structure_type = 'WORKPLAN'
                     )
              ) AS perc_complete
             FROM   pa_projects_all ppa
             WHERE  ppa.template_flag = 'N'
             ) qrslt
    ORDER  BY ngs DESC
    ;

  BEGIN
    fnd_file.put_line
    ( fnd_file.output
    , 'NGS;"Project name";"Created By";"Start date";"End Date";"Perc Complete"'
    );

    FOR r_proj IN c_proj
    LOOP
      fnd_file.put_line
      ( fnd_file.output
      , r_proj.ngs                              || ';"' ||
        r_proj.project_name                     || '";"' ||
        r_proj.created_by                       || '";' ||
        to_char(r_proj.start_date, 'dd-mon-yy') || ';' ||
        to_char(r_proj.end_date, 'dd-mon-yy')   || ';' ||
        to_char(nvl(r_proj.perc_complete, 0))
      );
    END LOOP;
    x_retcode := gc_retcode_succes;
  EXCEPTION
    WHEN OTHERS
    THEN
      x_retcode := gc_retcode_error;
  END project_reporting;

  /* ***************************************************************************
   * PROCEDURE   : negotiotion_reporting
   *
   * CALLED BY   : concurrent program
   *
   * DECSRIPTION :
   * Print comma seperated data from negotiations not in status DRAFT / DELETED.
   * Data printed is: Auction Type, Auction Number, Negotion Title, Created By
   * User Name
   * ***************************************************************************/
  PROCEDURE negotiation_reporting
  ( x_retbuf  OUT VARCHAR2
  , x_retcode OUT NUMBER)
  IS
    CURSOR c_neg
    IS
    SELECT fl1.meaning                       auction_type
    ,      ah.document_number                auction_number
    ,      ah.auction_title                  negotiation
    ,      ah.created_by_full_name           created_by
    ,      ah.close_bidding_date             close_date
    ,      to_char
           ( nvl
             ( ah.number_of_bids
             , 0
             )
           )                                 responses
    ,      fl2.meaning ||
           decode
           ( ah.bid_visibility_code
           , 'SEALED_AUCTION'
           , '(' || fl3.meaning || ')', ''
           )                                 status
    FROM   pon_auction_headers_v             ah
    ,      pon_auc_doctypes                  doc
    ,      fnd_lookups                       fl1
    ,      fnd_lookups                       fl2
    ,      fnd_lookups                       fl3
    WHERE  ah.auction_status                 <> 'DRAFT'
    AND    ah.auction_status                 <> 'DELETED'
    AND    ah.negotiation_status             = fl2.lookup_code
    AND    fl2.lookup_type                   = 'PON_AUCTION_STATUS'
    AND    nvl(ah.sealed_auction_status, '') = fl3.lookup_code(+)
    AND    fl3.lookup_type(+)                = 'PON_SEALED_AUCTION_STATUS'
    AND    ah.doctype_id                     = doc.doctype_id
    AND    fl1.lookup_type                   = 'PON_AUCTION_DOC_TYPES'
    AND    fl1.lookup_code                   = doc.internal_name
    ORDER BY fl1.meaning
    ,        ah.document_number DESC
    ;
  BEGIN
    fnd_file.put_line
    ( fnd_file.output
    , '"Auction Type";"Auction Number";"Negotiation";"Created By"'
    );

    FOR r_neg IN c_neg
    LOOP
      fnd_file.put_line
      ( fnd_file.output
      , r_neg.auction_type                     || ';"' ||
        r_neg.auction_number                   || '";"' ||
        r_neg.negotiation                      || '";"' ||
        r_neg.created_by                       || '";' ||
        to_char(r_neg.close_date, 'dd-mon-yy') || ';' ||
        to_char(nvl(r_neg.responses, 0))       || ';"' ||
        r_neg.status                           || '"'
      );
    END LOOP;
    x_retcode := gc_retcode_succes;
  EXCEPTION
    WHEN OTHERS
    THEN
      x_retcode := gc_retcode_error;
  END negotiation_reporting;
END XXAH_MGT_REP_PKG;

/
