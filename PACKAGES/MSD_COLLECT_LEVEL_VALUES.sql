--------------------------------------------------------
--  DDL for Package MSD_COLLECT_LEVEL_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_COLLECT_LEVEL_VALUES" AUTHID CURRENT_USER AS
/* $Header: msdclvls.pls 120.0 2005/05/25 20:31:05 appldev noship $ */

  -- C_SOP        CONSTANT NUMBER := 1;  --jarorad
  -- C_DP         CONSTANT NUMBER := 2;  --jarorad

  C_MSC_DEBUG   VARCHAR2(1)    := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

procedure collect_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_collection_type   IN  VARCHAR2,
                        p_collection_var    IN  VARCHAR2);
                      --  ,p_launched_from     IN NUMBER DEFAULT NULL);    --jarorad

procedure collect_level_parent_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_level_id          IN  NUMBER,
			p_parent_level_id   IN  NUMBER,
			p_update_lvl_table  IN  NUMBER);

procedure collect_level_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
			p_instance_id 	    IN  NUMBER,
                        p_level_id          IN  NUMBER);

procedure collect_hierarchy_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_hierarchy_id      IN  NUMBER);

procedure collect_dimension_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_dimension_code    IN  VARCHAR2);

procedure collect_dp_dimension_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
			p_demand_plan_id    IN  NUMBER,
                        p_dimension_code    IN  VARCHAR2);

procedure collect_demand_plan_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER,
                        p_demand_plan_id    IN  NUMBER);

procedure collect_all_data(
                        errbuf              OUT NOCOPY VARCHAR2,
                        retcode             OUT NOCOPY VARCHAR2,
                        p_instance_id       IN  NUMBER);


procedure fix_orphans(p_instance_id    in number,
                      p_level_id       in number,
                      p_dest_table     in varchar2,
                      p_dest_ass_table in varchar2,
                      p_hierarchy_id   in number);

Procedure  Delete_duplicate_lvl_assoc( errbuf              OUT NOCOPY VARCHAR2,
                                       retcode             OUT NOCOPY VARCHAR2,
                                       p_instance_id in number);

FUNCTION get_dest_table return varchar2;
FUNCTION get_assoc_table return varchar2;

END MSD_COLLECT_LEVEL_VALUES ;

 

/
