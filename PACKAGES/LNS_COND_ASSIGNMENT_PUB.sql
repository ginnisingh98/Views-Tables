--------------------------------------------------------
--  DDL for Package LNS_COND_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_COND_ASSIGNMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_CASGM_PUBP_S.pls 120.5.12010000.2 2010/03/17 13:39:34 scherkas ship $ */

TYPE cond_assignment_rec_type IS RECORD(
     COND_ASSIGNMENT_ID			      NUMBER,
     LOAN_ID                         NUMBER,
     CONDITION_ID              NUMBER,
     CONDITION_DESCRIPTION                    VARCHAR2(250),
     CONDITION_MET_FLAG                       VARCHAR2(1),
     FULFILLMENT_DATE                   DATE,
     FULFILLMENT_UPDATED_BY          NUMBER(15),
     MANDATORY_FLAG                           VARCHAR2(1),
     CREATED_BY                      NUMBER(15),
     CREATION_DATE                   DATE,
     LAST_UPDATED_BY                 NUMBER(15),
     LAST_UPDATE_DATE                DATE,
     LAST_UPDATE_LOGIN                        NUMBER(15),
     OBJECT_VERSION_NUMBER           NUMBER,
     DISB_HEADER_ID		     NUMBER,
     DELETE_DISABLED_FLAG	VARCHAR2(1),
     OWNER_OBJECT_ID	     NUMBER,
     OWNER_TABLE    VARCHAR2(100)
);
TYPE cond_assignment_tbl_type IS TABLE OF cond_assignment_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE create_COND_ASSIGNMENT (
    p_init_msg_list    IN         VARCHAR2,
    p_COND_ASSIGNMENT_rec   IN         cond_assignment_rec_type,
    x_COND_ASSIGNMENT_id    OUT NOCOPY NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_COND_ASSIGNMENT (
    p_init_msg_list         IN            VARCHAR2,
    p_COND_ASSIGNMENT_rec        IN            cond_assignment_rec_type,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE delete_COND_ASSIGNMENT (
    p_init_msg_list         IN            VARCHAR2,
    p_COND_ASSIGNMENT_id         IN		  NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);
/*
PROCEDURE get_COND_ASSIGNMENT_rec (
    p_init_msg_list   IN         VARCHAR2,
    p_COND_ASSIGNMENT_id         IN         NUMBER,
    x_COND_ASSIGNMENT_rec   OUT NOCOPY cond_assignment_rec_type,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
);
*/

PROCEDURE create_LP_COND_ASSIGNMENT( P_LOAN_ID IN NUMBER ) ;


PROCEDURE create_LP_DISB_COND_ASSIGNMENT(
            P_LOAN_ID IN NUMBER,
            P_DISB_HEADER_ID IN NUMBER ,
            P_LOAN_PRODUCT_LINE_ID IN NUMBER);

PROCEDURE delete_DISB_COND_ASSIGNMENT( P_DISB_HEADER_ID IN NUMBER ) ;


-- function used to check if any condition assignment exists for a specific condition
-- if so, disallow deletion of that condition in LNS_CONDITIONS
FUNCTION IS_EXIST_COND_ASSIGNMENT (
    p_condition_id			 NUMBER
) RETURN VARCHAR2;


PROCEDURE VALIDATE_CUSTOM_CONDITIONS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_OWNER_OBJECT_ID       IN          NUMBER,
    P_CONDITION_TYPE        IN          VARCHAR2,
    P_COMPLETE_FLAG         IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2);


PROCEDURE VALIDATE_CUSTOM_CONDITION(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_COND_ASSIGNMENT_ID    IN          NUMBER,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2);


PROCEDURE DEFAULT_COND_ASSIGNMENTS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_LOAN_ID               IN          NUMBER,
    P_OWNER_OBJECT_ID       IN          NUMBER,
    P_CONDITION_TYPE        IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2);

PROCEDURE VALIDATE_NONCUSTOM_CONDITIONS(
    P_API_VERSION		    IN          NUMBER,
    P_INIT_MSG_LIST		    IN          VARCHAR2,
    P_COMMIT			    IN          VARCHAR2,
    P_VALIDATION_LEVEL		IN          NUMBER,
    P_OWNER_OBJECT_ID       IN          NUMBER,
    P_CONDITION_TYPE        IN          VARCHAR2,
    X_RETURN_STATUS		    OUT NOCOPY  VARCHAR2,
    X_MSG_COUNT			    OUT NOCOPY  NUMBER,
    X_MSG_DATA	    		OUT NOCOPY  VARCHAR2);

END LNS_COND_ASSIGNMENT_PUB;

/
