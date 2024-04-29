--------------------------------------------------------
--  DDL for Package Body CAC_NOTE_PURGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_NOTE_PURGE_PUB" AS
/* $Header: cacntprb.pls 120.3 2005/09/13 10:49:41 abraina noship $ */
/*=======================================================================+
 |  Copyright (c) 2002 Oracle Corporation Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 | FILENAME                                                              |
 |   cacntprb.pls                                                        |
 |                                                                       |
 | DESCRIPTION                                                           |
 |   - This package is implemented for Notes purge program that would be |
 |     called from TASK or SR.                                           |
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | Date         Developer             Change                             |
 | ----------   ---------------       -----------------------------------|
 | 08-08-2005   Abhinav Raina         Created                            |
 +======================================================================*/

  Procedure purge_notes(
      p_api_version           IN   NUMBER,
      p_init_msg_list         IN   VARCHAR2 DEFAULT fnd_api.g_false,
      p_commit                IN   VARCHAR2 DEFAULT fnd_api.g_false,
      x_return_status         OUT  NOCOPY VARCHAR2,
      x_msg_data              OUT  NOCOPY VARCHAR2,
      x_msg_count             OUT  NOCOPY NUMBER,
      p_processing_set_id     IN   NUMBER,
      p_object_type           IN   VARCHAR2 )

      IS

      l_api_version	 CONSTANT NUMBER := 1.0;
      l_api_name	 CONSTANT VARCHAR2(30) := 'PURGE_NOTES';

  BEGIN

     SAVEPOINT purge_notes;
     x_return_status := fnd_api.g_ret_sts_success;

     IF NOT fnd_api.compatible_api_call (
		l_api_version,
		p_api_version,
		l_api_name,
		g_pkg_name
	     )
     THEN
	  RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF fnd_api.to_boolean (p_init_msg_list)
     THEN
	  fnd_msg_pub.initialize;
     END IF;

     --Logging input parameters

     IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
	 FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' p_object_type= '||p_object_type);
         FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' p_processing_set_id= '||p_processing_set_id);
     END IF;


     --Calling the CAC_NOTE_PURGE_PVT.PURGE_NOTES API

             CAC_NOTE_PURGE_PVT.PURGE_NOTES (
                      p_api_version        => p_api_version ,
                      p_init_msg_list      => p_init_msg_list,
                      p_commit             => p_commit,
                      x_return_status      => x_return_status,
                      x_msg_data           => x_msg_data,
                      x_msg_count          => x_msg_count,
                      p_processing_set_id  => p_processing_set_id,
                      p_object_type        => p_object_type ) ;


     IF NOT (x_return_status = fnd_api.g_ret_sts_success)
     THEN
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        RAISE fnd_api.g_exc_unexpected_error;
     END IF;

     IF fnd_api.to_boolean (p_commit)
     THEN
       COMMIT WORK;
     END IF;

     fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_unexpected_error
    THEN
	ROLLBACK TO purge_notes;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' x_return_status= '||x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' x_msg_data= '||x_msg_data);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' x_msg_count= '||x_msg_count);
      END IF;

    WHEN OTHERS
    THEN
        ROLLBACK TO purge_notes;
        fnd_message.set_name ('JTF', 'CAC_NOTE_UNKNOWN_ERROR');
        fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
        fnd_msg_pub.add;
        x_return_status := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
      IF( FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) then
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' x_return_status= '||x_return_status);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' x_msg_data= '||x_msg_data);
        FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,'cac_note_purge_pub.purge_notes', ' x_msg_count= '||x_msg_count);
      END IF;

 END purge_notes;

END;

/
