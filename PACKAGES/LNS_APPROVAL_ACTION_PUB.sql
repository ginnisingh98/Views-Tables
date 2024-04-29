--------------------------------------------------------
--  DDL for Package LNS_APPROVAL_ACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_APPROVAL_ACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_APACT_PUBP_S.pls 120.0.12010000.3 2010/04/15 12:48:21 scherkas ship $ */

TYPE approval_action_rec_type IS RECORD(
     ACTION_ID			     NUMBER,
     CREATED_BY                      NUMBER(15),
     CREATION_DATE                   DATE,
     LAST_UPDATED_BY                 NUMBER(15),
     LAST_UPDATE_DATE                DATE,
     LAST_UPDATE_LOGIN                        NUMBER(15),
     OBJECT_VERSION_NUMBER           NUMBER,
     LOAN_ID                         NUMBER,
     ACTION_TYPE		     VARCHAR2(30),
     AMOUNT			     NUMBER,
     REASON_CODE		     VARCHAR2(30),
     ATTRIBUTE_CATEGORY		     VARCHAR2(30),
     ATTRIBUTE1       VARCHAR2(150),
     ATTRIBUTE2       VARCHAR2(150),
     ATTRIBUTE3       VARCHAR2(150),
     ATTRIBUTE4       VARCHAR2(150),
     ATTRIBUTE5       VARCHAR2(150),
     ATTRIBUTE6       VARCHAR2(150),
     ATTRIBUTE7       VARCHAR2(150),
     ATTRIBUTE8       VARCHAR2(150),
     ATTRIBUTE9       VARCHAR2(150),
     ATTRIBUTE10      VARCHAR2(150),
     ATTRIBUTE11      VARCHAR2(150),
     ATTRIBUTE12      VARCHAR2(150),
     ATTRIBUTE13      VARCHAR2(150),
     ATTRIBUTE14      VARCHAR2(150),
     ATTRIBUTE15      VARCHAR2(150),
     ATTRIBUTE16      VARCHAR2(150),
     ATTRIBUTE17      VARCHAR2(150),
     ATTRIBUTE18      VARCHAR2(150),
     ATTRIBUTE19      VARCHAR2(150),
     ATTRIBUTE20      VARCHAR2(150)
);

PROCEDURE create_approval_action (
    p_init_msg_list    IN         VARCHAR2,
    p_approval_action_rec   IN         approval_action_rec_type,
    x_action_id		    OUT NOCOPY NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_approval_action (
    p_init_msg_list         IN            VARCHAR2,
    p_approval_action_rec        IN            approval_action_rec_type,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE delete_approval_action (
    p_init_msg_list         IN            VARCHAR2,
    p_action_id         IN		  NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);
/*
PROCEDURE get_approval_action_rec (
    p_init_msg_list   IN         VARCHAR2,
    p_action_id         IN         NUMBER,
    x_approval_action_rec   OUT NOCOPY approval_action_rec_type,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
);
*/

PROCEDURE APPROVE_ADD_RECEIVABLE(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_LINE_ID          IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);


PROCEDURE APPROVE_LOAN_AM_ADJ(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL	    IN          NUMBER,
    P_LOAN_AMOUNT_ADJ_ID    IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    	    OUT NOCOPY  VARCHAR2);


END LNS_APPROVAL_ACTION_PUB;

/
