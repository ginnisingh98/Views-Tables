--------------------------------------------------------
--  DDL for Package JTF_TTY_GEN_TERR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_TTY_GEN_TERR_PVT" AUTHID CURRENT_USER AS
/* $Header: jtftssts.pls 120.6 2006/07/11 21:24:53 mhtran ship $ */
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TTY_GEN_TERR_PVT
--    ---------------------------------------------------
--    PURPOSE
--      This package is used to generate the territories
--      based on different events like create territory group
--      update of a named account, etc.
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      12/07/04    SGKUMAR          Created
--
--    End of Comments

PROCEDURE generate_terr (
      errbuf                OUT NOCOPY      VARCHAR2,
      retcode               OUT NOCOPY      VARCHAR2,
      p_mode                IN              VARCHAR2,
      p_number_of_workers   IN              NUMBER,
      p_debug_flag          IN              VARCHAR2,
      p_sql_trace           IN              VARCHAR2);
/*----------------------------------------------------------
This procedure will create territories for territory group
which is updated or created. E.g. from create or update TG
----------------------------------------------------------*/
PROCEDURE create_terr_for_TG(p_terr_group_id           IN NUMBER
                            ,p_territory_type          IN VARCHAR2
                            ,p_change_type             IN VARCHAR2
                            ,p_terr_type_id            IN VARCHAR2
                            ,p_terr_id                 IN VARCHAR2
		            ,p_terr_creation_flag      IN VARCHAR2);

PROCEDURE delete_catch_all_terr_for_TG(p_terr_group_id IN NUMBER);


PROCEDURE delete_TGA(p_terr_grp_acct_id  IN NUMBER
                    ,p_terr_group_id     IN NUMBER
                    ,p_catchall_terr_id  IN NUMBER
                    ,p_change_type       IN VARCHAR2);

PROCEDURE Delete_Territory_or_tg(p_terr_Id IN VARCHAR2);

PROCEDURE delete_catchall_terrrsc_for_TG(p_terr_group_id IN NUMBER);

PROCEDURE create_catchall_terr_rsc(p_terr_group_id IN NUMBER
                                  ,p_org_id IN VARCHAR2
                                  ,p_resource_id IN NUMBER
                                  ,p_role_code IN VARCHAR2
                                  ,p_group_id IN NUMBER
			          ,p_user_id IN NUMBER);

/*----------------------------------------------------------
This procedure will delete territories for territory group
which is deleted. E.g. from Territory Groups Page
----------------------------------------------------------*/
PROCEDURE delete_TG(p_terr_grp_id           IN NUMBER,
                    p_terr_id               IN VARCHAR2,
	            p_terr_creation_flag    IN VARCHAR2
					   );
/*----------------------------------------------------------
This procedure will create or recreate territories for affected
tgas for named account
----------------------------------------------------------*/
PROCEDURE create_terr_for_na(p_terr_grp_acct_id      IN NUMBER,
                             p_terr_grp_id           IN NUMBER );
/*----------------------------------------------------------
This procedure will create or recreate territories for affected
geography territory
----------------------------------------------------------*/
PROCEDURE create_terr_for_gt(p_geo_terr_id        IN NUMBER
                             ,p_from_where          IN VARCHAR2);

/*----------------------------------------------------------
This procedure will delete territories from the JTF_TERR...
tables for the specified Terr Group Account Ids.
----------------------------------------------------------*/
PROCEDURE delete_bulk_TGA(p_terrGrpId_tbl IN jtf_terr_number_list,
                          p_grpAcctId_tbl IN jtf_terr_number_list,
                          p_change_type IN VARCHAR2,
                          x_return_status  OUT NOCOPY VARCHAR2,
                          x_msg_count      OUT NOCOPY NUMBER,
                          x_msg_data       OUT NOCOPY VARCHAR2);


/*----------------------------------------------------------
This procedure will update the sales team for a named account in
a territory group
----------------------------------------------------------*/
PROCEDURE update_terr_rscs_for_na(p_terr_grp_acct_id        IN NUMBER,
                                  p_terr_group_id           IN NUMBER);

PROCEDURE update_terr_for_na(p_terr_grp_acct_id        IN NUMBER,
                             p_terr_group_id           IN NUMBER);


END JTF_TTY_GEN_TERR_PVT;

 

/
