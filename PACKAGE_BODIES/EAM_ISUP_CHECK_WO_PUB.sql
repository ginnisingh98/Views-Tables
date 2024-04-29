--------------------------------------------------------
--  DDL for Package Body EAM_ISUP_CHECK_WO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_ISUP_CHECK_WO_PUB" AS
/* $Header: EAMISWPB.pls 120.1 2005/11/08 23:17:41 mmaduska noship $ */
/***************************************************************************
--
--  Copyright (c) 2002 Oracle Corporation, Redwood Shores, CA, USA
--  All rights reserved.
--
--  FILENAME
--
--      EAMISWPB.pls
--
--  DESCRIPTION
--
--      Body of package EAM_ISUP_CHECK_WO_PUB
--
--  NOTES
--
--  HISTORY
--
--  02-NOV-2005    Basanth Roy     Initial Creation
***************************************************************************/
g_pkg_name    CONSTANT VARCHAR2(30):= 'EAM_ISUP_CHECK_WO_PUB';


      PROCEDURE CHECK_WO_EXISTS
        (  p_bo_identifier           IN  VARCHAR2 := 'EAM'
         , p_api_version_number      IN  NUMBER := 1.0
         , p_init_msg_list           IN  BOOLEAN := FALSE
         , p_commit                  IN  VARCHAR2 := 'N'
         , p_header_id               IN  NUMBER
         , p_release_id              IN  NUMBER
         , x_wo_exists               OUT NOCOPY VARCHAR2
         , x_return_status           OUT NOCOPY VARCHAR2
         , x_msg_count               OUT NOCOPY NUMBER
         )
      IS

         l_count         NUMBER;
         l_module        VARCHAR2(50);
         l_message_text  VARCHAR2(4000);

      BEGIN

         l_module := 'EAM_ISUP_CHECK_WO_PUB';
         x_wo_exists := 'N';
         x_return_status := 'S';

         select count(pda.wip_entity_id)
         into l_count
         from
             po_distributions_all pda,
             wip_entities we
         where
           pda.po_header_id = p_header_id
           and pda.wip_entity_id = we.wip_entity_id
           and we.entity_type in (6,7);

         IF l_count > 0 THEN
           x_wo_exists := 'Y';
           RETURN;
         END IF;

         select count(pda.wip_entity_id)
         into l_count
         from
             po_distributions_all pda,
             wip_entities we
         where
           pda.po_release_id = p_release_id
           and pda.wip_entity_id = we.wip_entity_id
           and we.entity_type in (6,7);

         IF l_count > 0 THEN
           x_wo_exists := 'Y';
           RETURN;
         END IF;


         RETURN;


  EXCEPTION
        WHEN OTHERS THEN
          x_return_status := 'E';
          l_message_text := l_module||' failed with ' ||SQLERRM;
          RAISE_APPLICATION_ERROR(-20000, l_message_text);


END CHECK_WO_EXISTS;



END EAM_ISUP_CHECK_WO_PUB;

/
