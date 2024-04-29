--------------------------------------------------------
--  DDL for Package Body JTF_TERR_MERGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JTF_TERR_MERGE_PUB" AS
/* $Header: jtfptrmb.pls 120.3 2005/11/09 13:22:18 mhtran noship $ */
--    ---------------------------------------------------
--    Start of Comments
--    ---------------------------------------------------
--    PACKAGE NAME:   JTF_TERR_MERGE_PUB
--    ---------------------------------------------------
--    PURPOSE
--      Joint task force core territory manager public api's.
--      This package is a public API for party and
--      party site merge
--
--      Procedures:
--         (see below for specification)
--
--    NOTES
--      This package is publicly available for use
--
--    HISTORY
--      05/03/01    JDOCHERT     Created
--
--    End of Comments

/* ---------------------------- PARTY MERGE ------------------------
** procedure to merge parties: affects qualifiers with following ids:
** -1511, -1435, -1078, -1064, -1063, -1037, -1014, -1002
** ----------------------------------------------------------------- */
PROCEDURE party_merge( p_entity_name                IN   VARCHAR2,
                       p_from_id                    IN   NUMBER,
                       x_to_id                      OUT NOCOPY NUMBER,
           	       p_from_fk_id                 IN   NUMBER,
                       p_to_fk_id                   IN   NUMBER,
                       p_parent_entity_name         IN   VARCHAR2,
		       p_batch_id                   IN   NUMBER,
		       p_batch_party_id             IN   NUMBER,
		       x_return_status              OUT  NOCOPY VARCHAR2 )
IS


   l_api_name CONSTANT VARCHAR2(30) :=  'TERR_PARTY_MERGE';


BEGIN

   SAVEPOINT TERRITORY_PARTY_MERGE_PUB;

   x_return_status := fnd_api.g_ret_sts_success;

   IF ( p_entity_name <> 'JTF_TERR_VALUES_ALL' OR
        p_parent_entity_name <> 'HZ_PARTIES' ) THEN

       fnd_message.set_name ('JTF', 'JTF_TERR_ENTITY_NAME_ERR');
       fnd_message.set_token('P_ENTITY',p_entity_name);
       fnd_message.set_token('P_PARENT_ENTITY',p_parent_entity_name);
       FND_MSG_PUB.add;

       x_return_status := fnd_api.g_ret_sts_error;

   END IF;

   IF (p_from_FK_id <> p_to_FK_id) THEN

          UPDATE jtf_terr_values_all jtv
          SET jtv.low_value_char_id = p_to_fk_id
            , jtv.last_update_date = HZ_UTILITY_PUB.last_update_date
            , jtv.last_updated_by = HZ_UTILITY_PUB.last_updated_by
            , jtv.last_update_login = HZ_UTILITY_PUB.last_update_login
            WHERE jtv.low_value_char_id = p_from_FK_id
            AND EXISTS (
                SELECT jtq.terr_qual_id
                FROM jtf_terr_qual_all jtq
                WHERE jtq.qual_usg_id IN (-1511, -1435, -1078, -1064, -1063, -1037, -1014, -1002, -1001)
                  AND jtq.terr_qual_id = jtv.terr_qual_id
            );

          x_to_id := p_from_id;

   END IF;

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO TERR_PARTY_MERGE_PUB;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO TERR_PARTY_MERGE_PUB;

    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('P_SQLCODE', SQLCODE);
      fnd_message.set_token('P_SQLERRM', SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO TERR_PARTY_MERGE_PUB;

END party_merge;



/* ---------------------------- PARTY SITE MERGE ------------------------
** procedure to merge party sites: affects qualifiers with following ids:
** -1094, -1093, -1077, -1039, -1005
** ----------------------------------------------------------------- */
PROCEDURE party_site_merge(
                       p_entity_name                IN   VARCHAR2,
                       p_from_id                    IN   NUMBER,
                       x_to_id                      OUT NOCOPY NUMBER,
           		       p_from_fk_id                 IN   NUMBER,
                       p_to_fk_id                   IN   NUMBER,
                       p_parent_entity_name         IN   VARCHAR2,
			           p_batch_id                   IN   NUMBER,
			           p_batch_party_id             IN   NUMBER,
			           x_return_status              OUT NOCOPY VARCHAR2 )
IS


   l_api_name CONSTANT VARCHAR2(30) :=  'TERR_PARTY_SITE_MERGE';

BEGIN

   SAVEPOINT TERR_PARTY_SITE_MERGE_PUB;

   x_return_status := fnd_api.g_ret_sts_success;


   IF ( p_entity_name <> 'JTF_TERR_VALUES_ALL' OR
        p_parent_entity_name <> 'HZ_PARTY_SITES' ) THEN

       fnd_message.set_name ('JTF', 'JTF_TERR_ENTITY_NAME_ERR');
       fnd_message.set_token('P_ENTITY', p_entity_name);
       fnd_message.set_token('P_PARENT_ENTITY', p_parent_entity_name);
       FND_MSG_PUB.add;

       x_return_status := fnd_api.g_ret_sts_error;

   END IF;

   IF (p_from_FK_id <> p_to_FK_id) THEN

          UPDATE jtf_terr_values_all jtv
          SET jtv.low_value_char_id = p_to_fk_id
            , jtv.last_update_date = HZ_UTILITY_PUB.last_update_date
            , jtv.last_updated_by = HZ_UTILITY_PUB.last_updated_by
            , jtv.last_update_login = HZ_UTILITY_PUB.last_update_login
          WHERE jtv.low_value_char_id = p_from_FK_id
            AND EXISTS (
                SELECT jtq.terr_qual_id
                FROM jtf_terr_qual_all jtq
                WHERE jtq.qual_usg_id IN (-1094, -1093, -1077, -1039, -1005)
                  AND jtq.terr_qual_id = jtv.terr_qual_id
            );

          x_to_id := p_from_id;

   END IF;

   IF (x_return_status <> fnd_api.g_ret_sts_success) THEN
      RAISE fnd_api.g_exc_error;
   END IF;

EXCEPTION

    WHEN fnd_api.g_exc_unexpected_error THEN
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO TERR_PARTY_SITE_MERGE_PUB;

    WHEN fnd_api.g_exc_error THEN
      x_return_status := fnd_api.g_ret_sts_error;
      ROLLBACK TO TERR_PARTY_SITE_MERGE_PUB;

    WHEN OTHERS THEN
      fnd_message.set_name('AR', 'HZ_API_OTHERS_EXCEP');
      fnd_message.set_token('P_SQLCODE',SQLCODE);
      fnd_message.set_token('P_SQLERRM',SQLERRM);
      fnd_message.set_token('P_API_NAME', l_api_name);
      FND_MSG_PUB.add;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      ROLLBACK TO TERR_PARTY_SITE_MERGE_PUB;

END party_site_merge;

END JTF_TERR_MERGE_PUB;

/
