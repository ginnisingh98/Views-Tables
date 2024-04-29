--------------------------------------------------------
--  DDL for Package IGS_PE_CONFIG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_CONFIG_PVT" AUTHID CURRENT_USER AS
/* $Header: IGSPE09S.pls 115.4 2002/11/29 01:51:26 nsidana noship $ */
/*************************************************************************
   Created By		    :	mesriniv
   Date Created By	    :	2002/02/03
   Purpose		    :	To be used in Self Service Build,to check if
	                        student latest info is available in the System
   Known Limitations,Enhancements or Remarks
   Change History	:
   Who			When		What
   ssawhney            19feb            changed the naming conventions.
   ssawhney            22aug            Bug 2524217 :  p_commit defaulted in spec to TRUE.
   **********************************************************************/

  -- Returns true if the person needs to perform verification, based on user's profile setup
    PROCEDURE verify_pe_info(
                                 p_person_id          IN   NUMBER,
				 p_api_version        IN   NUMBER  ,
                                 p_init_msg_list      IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                                 p_commit             IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                                 p_validation_level   IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_NONE,
				 x_result             OUT NOCOPY  VARCHAR2,
                                 x_return_status      OUT NOCOPY  VARCHAR2,
                                 x_msg_count          OUT NOCOPY  NUMBER,
                                 x_msg_data           OUT NOCOPY  VARCHAR2
                               ) ;

-- Reset the person s last verification date with SYSDATE
    PROCEDURE set_pe_info_verify_time(
                                 p_person_id          IN   NUMBER,
				 p_api_version        IN   NUMBER  ,
                                 p_init_msg_list      IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
                                 p_commit             IN   VARCHAR2 DEFAULT FND_API.G_TRUE,
                                 p_validation_level   IN   NUMBER   DEFAULT FND_API.G_VALID_LEVEL_NONE,
                                 x_return_status      OUT NOCOPY  VARCHAR2,
                                 x_msg_count          OUT NOCOPY  NUMBER,
                                 x_msg_data           OUT NOCOPY  VARCHAR2
                                );

END igs_pe_config_pvt;

 

/
