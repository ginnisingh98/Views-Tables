--------------------------------------------------------
--  DDL for Package Body AZ_VALIDATE_ACTIVE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AZ_VALIDATE_ACTIVE" AS
/* $Header: azvalidateactvb.pls 120.4 2006/07/21 09:31:27 gagupta noship $ */

  PROCEDURE validate_selsets AS
  BEGIN

    UPDATE az_selection_sets_b
       SET active = 'N'
     WHERE selection_set_code IN
           (SELECT selection_set_code
              FROM az_selection_sets_b
             WHERE user_id <> 1
               AND structure_code IN (SELECT structure_code
                                        FROM az_structures_b
                                       WHERE active = 'N'));
    COMMIT;

  END validate_selsets;


  PROCEDURE validate_transforms AS
  BEGIN

    UPDATE az_requests
       SET active='N'
     WHERE request_type = 'T'
       AND selection_set IS NULL;

    UPDATE az_requests req
       SET req.active = (
              SELECT decode(strct.active, 'N', 'N', NULL, 'N', 'Y')
                FROM az_structures_b strct
               WHERE structure_code =
                     (SELECT extractvalue(VALUE(e),
                                          '/H/V[@N="StructureCode"]/text()')
                        FROM az_requests d,
                             TABLE(xmlsequence(extract(d.selection_set,
                                                       '/EXT/H/V[@N="StructureCode"]/..'))) e
                       WHERE req.job_name = d.job_name
                         AND req.user_id = d.user_id
                         AND req.request_type = d.request_type
                         AND d.selection_set IS NOT NULL))
     WHERE req.request_type = 'T'
       AND req.selection_set IS NOT NULL;

    COMMIT;

  END validate_transforms;

  PROCEDURE validate_loads AS
  BEGIN

    UPDATE az_requests
       SET active='N'
     WHERE request_type = 'L'
       AND selection_set IS NULL;

    UPDATE az_requests req
       SET req.active = (
              SELECT decode(strct.active, 'N', 'N', NULL, 'N', 'Y')
                FROM az_structures_b strct
               WHERE structure_code =
                     (SELECT extractvalue(VALUE(e),
                                          '/H/V[@N="StructureCode"]/text()')
                        FROM az_requests d,
                             TABLE(xmlsequence(extract(d.selection_set,
                                                       '/EXT/H/V[@N="StructureCode"]/..'))) e
                       WHERE req.job_name = d.job_name
                         AND req.user_id = d.user_id
                         AND req.request_type = d.request_type
                         AND d.selection_set IS NOT NULL))
     WHERE req.request_type = 'L'
       AND req.selection_set IS NOT NULL;

    COMMIT;

  END validate_loads;

  PROCEDURE activate_apis AS
  BEGIN

    UPDATE az_apis
       SET active = 'Y'
     WHERE api_code IN (
              SELECT DISTINCT api.api_code
                FROM az_structures_b             strct,
                     az_selection_sets_b         sset,
                     az_selection_set_entities_b ent,
                     az_structure_apis_b         sapi,
                     az_apis                     api
               WHERE strct.structure_code = sset.structure_code
                 AND strct.structure_code = sapi.structure_code
                 AND sset.selection_set_code = ent.selection_set_code
                 AND sapi.api_code = api.api_code
                 AND strct.active = 'Y'
                 AND api.active IS NULL);

    COMMIT;

  END activate_apis;

  PROCEDURE validate_extracts AS
  BEGIN

    activate_apis;

    UPDATE az_requests
       SET active='N'
     WHERE request_type = 'E'
       AND selection_set IS NULL;

    UPDATE az_requests
       SET active = 'N'
     WHERE request_type = 'E'
       AND request_phase <> 'C'
       AND request_status <> 'C'
       AND selection_set IS NOT NULL;

    UPDATE az_requests req
       SET req.active = (
              SELECT decode(COUNT(api.active), 0, 'N', 'R')
                FROM az_structures_b strct, az_apis api
               WHERE strct.structure_code = -- query b
                     (SELECT extractvalue(VALUE(e),
                                          '/H/V[@N="StructureCode"]/text()')
                        FROM az_requests d,
                             TABLE(xmlsequence(extract(d.selection_set,
                                                       '/EXT/H/V[@N="StructureCode"]/..'))) e
                       WHERE req.job_name = d.job_name
                         AND req.user_id = d.user_id
                         AND req.request_type = d.request_type
                         AND d.selection_set IS NOT NULL)
                 AND strct.active = 'N'
                 AND api.api_code IN -- 2
                     (SELECT api_code
                        FROM az_structure_apis_b
                       WHERE structure_code IN
                             (SELECT extractvalue(VALUE(e),
                                                  '/H/V[@N="StructureCode"]/text()')
                                FROM az_requests d,
                                     TABLE(xmlsequence(extract(d.selection_set,
                                                               '/EXT/H/V[@N="StructureCode"]/..'))) e
                               WHERE d.job_name = req.job_name
                                 AND d.request_type = req.request_type
                                 AND d.user_id = req.user_id -- 2's first where
                                 AND d.selection_set IS NOT NULL)
                         AND entity_code IN (SELECT extractvalue(VALUE(e),
                                                                 '/H/V[@N="EntityOccuranceCode"]/text()')
                                               FROM az_requests d,
                                                    TABLE(xmlsequence(extract(d.selection_set,
                                                                              '/EXT/H/V[@N="EntityOccuranceCode"]/..'))) e
                                              WHERE d.job_name = req.job_name
                                                AND d.request_type = req.request_type
                                                AND d.user_id = req.user_id -- 2's second where
                                                AND d.selection_set IS NOT NULL))
                 AND api.active = 'Y')
     WHERE req.request_type = 'E'
       AND req.request_phase = 'C'
       AND req.request_status = 'C'
       AND req.selection_set IS NOT NULL;

   UPDATE az_requests req
       SET req.active = (decode(
              (SELECT 'Y'
                FROM az_structures_b strct
               WHERE structure_code = -- query b
                     (SELECT extractvalue(VALUE(e),
                                          '/H/V[@N="StructureCode"]/text()')
                        FROM az_requests d,
                             TABLE(xmlsequence(extract(d.selection_set,
                                                       '/EXT/H/V[@N="StructureCode"]/..'))) e
                       WHERE req.job_name = d.job_name
                         AND req.user_id = d.user_id
                         AND req.request_type = d.request_type
                         AND d.selection_set IS NOT NULL)
                 AND strct.active <> 'N'
                 AND strct.active IS NOT NULL),null,req.active,'Y'))
	       WHERE req.request_type = 'E'
	         AND req.request_phase = 'C'
	         AND req.request_status = 'C'
	         AND req.selection_set IS NOT NULL;

    COMMIT;

  END validate_extracts;

  FUNCTION validate_active_request(p_job_name     IN VARCHAR2,
                                   p_request_type IN VARCHAR2,
                                   p_user_id      IN NUMBER) RETURN VARCHAR2 AS
  v_active VARCHAR2(1);
  BEGIN

    activate_apis;

    UPDATE az_requests
       SET active='N'
     WHERE selection_set IS NULL
       AND job_name=p_job_name
       AND request_type=p_request_type
       AND user_id=p_user_id;

    UPDATE az_requests req
       SET req.active = (
              SELECT decode(COUNT(api.active), 0, 'N', 'R')
                FROM az_structures_b strct, az_apis api
               WHERE strct.structure_code = -- query b
                     (SELECT extractvalue(VALUE(e),
                                          '/H/V[@N="StructureCode"]/text()')
                        FROM az_requests d,
                             TABLE(xmlsequence(extract(d.selection_set,
                                                       '/EXT/H/V[@N="StructureCode"]/..'))) e
                       WHERE req.job_name = d.job_name
                         AND req.user_id = d.user_id
                         AND req.request_type = d.request_type
                         AND d.selection_set IS NOT NULL)
                 AND strct.active = 'N'
                 AND api.api_code IN -- 2
                     (SELECT api_code
                        FROM az_structure_apis_b
                       WHERE structure_code IN
                             (SELECT extractvalue(VALUE(e),
                                                  '/H/V[@N="StructureCode"]/text()')
                                FROM az_requests d,
                                     TABLE(xmlsequence(extract(d.selection_set,
                                                               '/EXT/H/V[@N="StructureCode"]/..'))) e
                               WHERE d.job_name = req.job_name
                                 AND d.request_type = req.request_type
                                 AND d.user_id = req.user_id -- 2's first where
                                 AND d.selection_set IS NOT NULL)
                         AND entity_code IN (SELECT extractvalue(VALUE(e),
                                                                 '/H/V[@N="EntityOccuranceCode"]/text()')
                                               FROM az_requests d,
                                                    TABLE(xmlsequence(extract(d.selection_set,
                                                                              '/EXT/H/V[@N="EntityOccuranceCode"]/..'))) e
                                              WHERE d.job_name = req.job_name
                                                AND d.request_type = req.request_type
                                                AND d.user_id = req.user_id -- 2's second where
                                                AND d.selection_set IS NOT NULL))
                 AND api.active = 'Y')
     WHERE req.selection_set IS NOT NULL
       AND req.job_name=p_job_name
       AND req.request_type=p_request_type
       AND req.user_id=p_user_id;

    UPDATE az_requests req
       SET req.active = (decode(
              (SELECT 'Y'
                FROM az_structures_b strct
               WHERE structure_code = -- query b
                     (SELECT extractvalue(VALUE(e),
                                          '/H/V[@N="StructureCode"]/text()')
                        FROM az_requests d,
                             TABLE(xmlsequence(extract(d.selection_set,
                                                       '/EXT/H/V[@N="StructureCode"]/..'))) e
                       WHERE req.job_name = d.job_name
                         AND req.user_id = d.user_id
                         AND req.request_type = d.request_type
                         AND d.selection_set IS NOT NULL)
                 AND strct.active <> 'N'
                 AND strct.active IS NOT NULL),null,req.active,'Y'))
     WHERE req.selection_set IS NOT NULL
       AND req.job_name=p_job_name
       AND req.request_type=p_request_type
       AND req.user_id=p_user_id;

    COMMIT;

    SELECT active
      INTO v_active
      FROM az_requests
     WHERE job_name = p_job_name
       AND request_type = p_request_type
       AND user_id = p_user_id;

    RETURN v_active;

  END validate_active_request;

  PROCEDURE validate_active AS
  BEGIN

    validate_selsets;
    validate_extracts;
    validate_loads;
    validate_transforms;

  END validate_active;

END az_validate_active;

/
