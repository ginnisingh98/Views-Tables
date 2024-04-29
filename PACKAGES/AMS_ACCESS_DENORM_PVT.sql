--------------------------------------------------------
--  DDL for Package AMS_ACCESS_DENORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_ACCESS_DENORM_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvdens.pls 115.7 2003/02/12 11:36:44 sunkumar ship $ */


   PROCEDURE insert_resource( p_resource_id    IN  NUMBER
                            , p_object_type    IN  VARCHAR2
                            , p_object_id      IN  NUMBER
                            , p_edit_metrics   IN  VARCHAR2
                            , x_return_status  OUT NOCOPY VARCHAR2
			    , x_msg_count      OUT NOCOPY NUMBER
			    , x_msg_data       OUT NOCOPY VARCHAR2
                            );

   PROCEDURE update_resource( p_resource_id    IN  NUMBER
                            , p_object_type    IN  VARCHAR2
                            , p_object_id      IN  NUMBER
                            , p_edit_metrics   IN  VARCHAR2
                            , x_return_status  OUT NOCOPY VARCHAR2
			    , x_msg_count      OUT NOCOPY NUMBER
			    , x_msg_data       OUT NOCOPY VARCHAR2
                            );


   PROCEDURE delete_resource( p_resource_id    IN  NUMBER
                            , p_object_type    IN  VARCHAR2
                            , p_object_id      IN  NUMBER
                            , p_edit_metrics   IN  VARCHAR2
                            , x_return_status  OUT NOCOPY VARCHAR2
			    , x_msg_count      OUT NOCOPY NUMBER
			    , x_msg_data       OUT NOCOPY VARCHAR2
                            );

  /* This procedure inserts a resource for a given object into ams_act_access_denorm
     evaluating edit_metrics.  If a resource that is being inserted already exists, it
     checks for the edit metrics. If the existing value is 'N' and the incoming parameter
     is 'Y' it updates the row  */

   PROCEDURE insert_resource( p_resource_id    IN  NUMBER
                            , p_object_type    IN  VARCHAR2
                            , p_object_id      IN  NUMBER
                            , p_edit_metrics   IN  VARCHAR2
                            , x_return_status  OUT NOCOPY VARCHAR2
                            );

 /*  This procedure updates a resource for a given object in ams_act_access_denorm
     evaluating edit_metrics.  If incoming edit metrics is N and the existing value
     is 'Y', it checks to see if the resource is part of any other group with 'Y' access
     if it finds a matching 'Y' row, this procedure will not do any thing other wise it
     updates the resource  */

   PROCEDURE update_resource( p_resource_id    IN  NUMBER
                            , p_object_type    IN  VARCHAR2
                            , p_object_id      IN  NUMBER
                            , p_edit_metrics   IN  VARCHAR2
                            , x_return_status  OUT NOCOPY VARCHAR2
                            );
 /*  This procedure deletes a resource from the denorm, before deleting it will check
     if this resource exists as part of any other group than the one that is being deleted
     if assumes that delete from ams_act_access already happened*/

   PROCEDURE delete_resource( p_resource_id    IN  NUMBER
                            , p_object_type    IN  VARCHAR2
                            , p_object_id      IN  NUMBER
                            , p_edit_metrics   IN  VARCHAR2
                            , x_return_status  OUT NOCOPY VARCHAR2
                            );
  /* This procedure inserts a resource for a given object into ams_act_access_denorm
     evaluating edit_metrics.  If a resource that is being inserted already exists, it
     checks for the edit metrics. If the existing value is 'N' and the incoming parameter
     is 'Y' it updates the row  */

   PROCEDURE insert_resource( p_resource_id     IN  NUMBER
                            , p_object_type     IN  VARCHAR2
                            , p_object_id       IN  NUMBER
                            , p_edit_metrics    IN  VARCHAR2
                            );
 /*  This procedure updates a resource for a given object in ams_act_access_denorm
     evaluating edit_metrics.  If incoming edit metrics is N and the existing value
     is 'Y', it checks to see if the resource is part of any other group with 'Y' access
     if it finds a matching 'Y' row, this procedure will not do any thing other wise it
     updates the resource  */

   PROCEDURE update_resource( p_resource_id     IN  NUMBER
                            , p_object_type     IN  VARCHAR2
                            , p_object_id       IN  NUMBER
                            , p_edit_metrics    IN  VARCHAR2
                           );
 /*  This procedure deletes a resource from the denorm, before deleting it will check
     if this resource exists as part of any other group than the one that is being deleted
     if assumes that delete from ams_act_access already happened*/

   PROCEDURE delete_resource( p_resource_id     IN  NUMBER
                            , p_object_type     IN  VARCHAR2
                            , p_object_id       IN  NUMBER
                            , p_edit_metrics    IN  VARCHAR2
                            );
  /* This procedure inserts group information ( all the resources in the group and its children)
     into the denorm table.  It evaluates to see if the resource is part of another group with
     a different edit metrics and inserts/updates accordingly */
   PROCEDURE insert_group( p_group_id      IN  NUMBER
                         , p_object_type   IN  VARCHAR2
                         , p_object_id     IN  NUMBER
                         , p_edit_metrics  IN  VARCHAR2
                         );
   /* deletes resources present in the group and its children groups in the denorm table*/
   PROCEDURE delete_group( p_group_id      IN  NUMBER
                         , p_object_type   IN  VARCHAR2
                         , p_object_id     IN  NUMBER
                         , p_edit_metrics  IN  VARCHAR2
                         );

   PROCEDURE update_group( p_group_id      IN  NUMBER
                         , p_object_type   IN  VARCHAR2
                         , p_object_id     IN  NUMBER
                         , p_edit_metrics  IN  VARCHAR2
                         );
   /*  This procedure will be used as a concurrent program.  This program will refresh the entries
       in the denorm table for the object in context */
   PROCEDURE ams_object_denorm ( errbuf       OUT NOCOPY VARCHAR2
                               , retcode      OUT NOCOPY VARCHAR2
                               , p_object_id   IN NUMBER
                               , p_object_type IN VARCHAR2
                                );
 /*  This procedure will be used as a concurrent program.  This program will refresh the entries
     in the denorm table for all of the objects since the last run or complete refresh*/
AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE ams_access_denorm (  errbuf  OUT NOCOPY VARCHAR2
                             , retcode OUT NOCOPY VARCHAR2
                             , p_full_mode IN  VARCHAR2 := Fnd_Api.G_FALSE
                            );


 /*  This procedure will be used as a concurrent program.  This program will refresh the entries
     in the denorm table for all of the changes to groups done through resource manager*/
   PROCEDURE jtf_access_denorm(  errbuf  OUT NOCOPY VARCHAR2
                               , retcode OUT NOCOPY VARCHAR2
                              );

END ams_access_denorm_pvt;

 

/
