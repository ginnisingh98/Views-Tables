--------------------------------------------------------
--  DDL for Package MSD_TRANSLATE_LEVEL_VALUES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSD_TRANSLATE_LEVEL_VALUES" AUTHID CURRENT_USER AS
/* $Header: msdtlvls.pls 120.0 2005/05/25 20:16:23 appldev noship $ */

   --C_SOP        CONSTANT NUMBER := 1;  --jarorad
   --C_DP         CONSTANT NUMBER := 2;  --jarorad

   C_MSC_DEBUG   VARCHAR2(1)    := nvl(FND_PROFILE.Value('MRP_DEBUG'),'N');

procedure translate_level_parent_values(
                        errbuf                          OUT NOCOPY VARCHAR2,
                        retcode                         OUT NOCOPY VARCHAR2,
                        p_source_table                  IN  VARCHAR2,
                        p_dest_table                    IN  VARCHAR2,
                        p_instance_id                   IN  NUMBER,
                        p_level_id                      IN  NUMBER,
                        p_level_value_column            IN  VARCHAR2,
                        p_level_value_pk_column         IN  VARCHAR2,
                        p_level_value_desc_column       IN  VARCHAR2,
                        p_parent_level_id               IN  NUMBER,
                        p_parent_value_column           IN  VARCHAR2,
                        p_parent_value_pk_column        IN  VARCHAR2,
                        p_parent_value_desc_column      IN  VARCHAR2,
			p_update_lvl_table		IN  NUMBER,
                        p_delete_flag                   IN  VARCHAR2,
                        p_seq_num                       IN  NUMBER);
                        --,p_launched_from                 IN  NUMBER);  --jarorad

/*
procedure backup_level_values(p_level_id number,
                              p_parent_level_id number,
                              p_instance varchar2);


PROCEDURE backup_level_associations(
                                    p_level_id number,
                                    p_parent_level_id number,
                                    p_instance varchar2);

*/

PROCEDURE CLEAN_DELETED_LEVEL_VALUES(errbuf             OUT NOCOPY VARCHAR2,
                                    retcode             OUT NOCOPY VARCHAR2);



END MSD_TRANSLATE_LEVEL_VALUES ;

 

/
