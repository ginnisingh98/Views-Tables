--------------------------------------------------------
--  DDL for Package Body IGW_PROP_PROGRAM_ADDRESSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGW_PROP_PROGRAM_ADDRESSES_PVT" AS
--$Header: igwvpadb.pls 120.3 2005/09/12 21:06:12 vmedikon ship $

------------------------------------------------------------------------------------
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
 , x_msg_data                     OUT NOCOPY VARCHAR2)  is

  l_count                    NUMBER(10);
  l_proposal_id              igw_proposals_all.proposal_id%TYPE   := p_proposal_id;
  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_address_id               NUMBER            := p_address_id;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;

BEGIN
     null;

END; --CREATE MAILING INFO

---------------------------------------------------------------------

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
 , x_msg_data                     OUT NOCOPY VARCHAR2)   is

  l_proposal_id              igw_proposals_all.proposal_id%TYPE   := p_proposal_id;
  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_address_id               NUMBER            :=p_address_id;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_rowid                    ROWID :=NULL;
  l_dummy                    VARCHAR2(1);
  l_count                    NUMBER(10);


BEGIN
     null;

END; --UPDATE MAILING INFO
-------------------------------------------------------------------------------------

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
 , x_msg_data                     OUT NOCOPY VARCHAR2)  is

  l_proposal_id              igw_proposals_all.proposal_id%TYPE  := p_proposal_id;
  l_return_status            VARCHAR2(1);
  l_error_msg_code           VARCHAR2(250);
  l_msg_count                NUMBER;
  l_data                     VARCHAR2(250);
  l_address_id               NUMBER;
  l_msg_data                 VARCHAR2(250);
  l_msg_index_out            NUMBER;
  l_dummy                    VARCHAR2(1);
BEGIN
     null;

END; --DELETE MAILING INFO

END IGW_PROP_PROGRAM_ADDRESSES_PVT;

/
