--------------------------------------------------------
--  DDL for Package IGW_PROP_PROGRAM_ADDRESSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGW_PROP_PROGRAM_ADDRESSES_PVT" AUTHID CURRENT_USER AS
--$Header: igwvpads.pls 115.4 2002/11/15 00:43:39 ashkumar ship $

PROCEDURE CREATE_MAILING_INFO
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_address_id                   IN NUMBER
 , p_address                      IN VARCHAR2
 , p_mail_description             IN VARCHAR2
 , p_number_of_copies	          IN VARCHAR2
 , x_rowid                        OUT NOCOPY ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2) ;


PROCEDURE UPDATE_MAILING_INFO
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_address_id                   IN NUMBER
 , p_address                      IN VARCHAR2
 , p_mail_description             IN VARCHAR2
 , p_number_of_copies	          IN VARCHAR2
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);


PROCEDURE DELETE_MAILING_INFO
(p_init_msg_list                  IN VARCHAR2   := FND_API.G_TRUE
 , p_commit                       IN VARCHAR2   := FND_API.G_FALSE
 , p_validate_only                IN VARCHAR2   := FND_API.G_TRUE
 , p_proposal_id                  IN NUMBER
 , p_proposal_number              IN VARCHAR2
 , p_address_id                   IN NUMBER
 , p_record_version_number        IN NUMBER
 , p_rowid                        IN ROWID
 , x_return_status                OUT NOCOPY VARCHAR2
 , x_msg_count                    OUT NOCOPY NUMBER
 , x_msg_data                     OUT NOCOPY VARCHAR2);


END IGW_PROP_PROGRAM_ADDRESSES_PVT;

 

/
