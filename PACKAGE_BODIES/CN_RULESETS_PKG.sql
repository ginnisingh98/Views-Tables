--------------------------------------------------------
--  DDL for Package Body CN_RULESETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_RULESETS_PKG" AS
-- $Header: cnrulstb.pls 120.3 2005/06/28 22:53:49 appldev ship $

-- Function Name:	Sync_ruleset
-- Purpose
-- This function is used to synchronize a ruleset

PROCEDURE Sync_ruleset(x_ruleset_id_in cn_rulesets.ruleset_id%TYPE,
		       x_ruleset_status_in IN OUT NOCOPY cn_rulesets.ruleset_status%TYPE,
		       x_org_id cn_rulesets.org_id%TYPE) IS
  CURSOR get_ruleset_data IS
    SELECT *
      FROM cn_rulesets
     WHERE ruleset_id = x_ruleset_id_in and
     org_id=x_org_id;

  l_get_ruleset_data_rec get_ruleset_data%ROWTYPE;


BEGIN


  IF cn_classification_gen.revenue_classes(NULL, NULL, -1000,
					    x_ruleset_id_in,
					    x_org_id) THEN
    x_ruleset_status_in := 'INSTINPG';
  ELSE
    x_ruleset_status_in := 'UNSYNC';
  END IF;

  OPEN get_ruleset_data;
    FETCH get_ruleset_data INTO l_get_ruleset_data_rec;

    cn_syin_rulesets_pkg.update_row(x_ruleset_id_in,
                                   l_get_ruleset_data_rec.object_version_number,
                                   x_ruleset_status_in,
                                   l_get_ruleset_data_rec.destination_column_id,
                                   l_get_ruleset_data_rec.repository_id,
				   l_get_ruleset_data_rec.start_date,
				   l_get_ruleset_data_rec.end_date,
                                   l_get_ruleset_data_rec.name,
				   l_get_ruleset_data_rec.module_type,
                                   null,
                                   null,
                                   null,
				   x_org_id);
  CLOSE get_ruleset_data;
  --COMMIT;

END Sync_ruleset;

-- Function Name:	Unsync_ruleset
-- Purpose
-- This function is used to unsynchronize a ruleset

PROCEDURE Unsync_ruleset(x_ruleset_id_in cn_rulesets.ruleset_id%TYPE,
			 x_ruleset_status_in IN OUT NOCOPY cn_rulesets.ruleset_status%TYPE,
			 x_org_id cn_rulesets.org_id%TYPE) IS

  CURSOR get_ruleset_data IS
    SELECT *
      FROM cn_rulesets
     WHERE ruleset_id = x_ruleset_id_in and org_id=x_org_id;

  l_get_ruleset_data_rec get_ruleset_data%ROWTYPE;
BEGIN



 --  need to uncomment when changing cn_rule_attribute_pvt
  x_ruleset_status_in := 'UNSYNC';
  OPEN get_ruleset_data;
    FETCH get_ruleset_data INTO l_get_ruleset_data_rec;


    cn_syin_rulesets_pkg.update_row(x_ruleset_id_in,
                                   l_get_ruleset_data_rec.object_version_number,
                                   x_ruleset_status_in,
                                   l_get_ruleset_data_rec.destination_column_id,
                                   l_get_ruleset_data_rec.repository_id,
				   l_get_ruleset_data_rec.start_date,
				   l_get_ruleset_data_rec.end_date,
                                   l_get_ruleset_data_rec.name,
				   l_get_ruleset_data_rec.module_type,
                                   null,
                                   null,
                                   null,
				   x_org_id);

  CLOSE get_ruleset_data;
  --COMMIT;
END Unsync_ruleset;

END cn_rulesets_pkg;

/
