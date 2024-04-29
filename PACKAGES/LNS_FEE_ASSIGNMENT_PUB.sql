--------------------------------------------------------
--  DDL for Package LNS_FEE_ASSIGNMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."LNS_FEE_ASSIGNMENT_PUB" AUTHID CURRENT_USER AS
/* $Header: LNS_FASGM_PUBP_S.pls 120.5.12010000.6 2010/02/24 01:51:18 mbolli ship $ */

TYPE fee_assignment_rec_type IS RECORD(
     fee_assignment_id			      NUMBER,
     LOAN_ID                         NUMBER,
     FEE_ID              NUMBER,
     FEE                                      NUMBER,
     FEE_TYPE                                 VARCHAR2(30),
     FEE_BASIS                                VARCHAR2(30),
     NUMBER_GRACE_DAYS                        NUMBER,
     COLLECTED_THIRD_PARTY_FLAG		      VARCHAR2(1),
     RATE_TYPE				      VARCHAR2(30),
     BEGIN_INSTALLMENT_NUMBER		      NUMBER,
     END_INSTALLMENT_NUMBER		      NUMBER,
     NUMBER_OF_PAYMENTS			      NUMBER,
     BILLING_OPTION			      VARCHAR2(30),
     CREATED_BY                      NUMBER(15),
     CREATION_DATE                   DATE,
     LAST_UPDATED_BY                 NUMBER(15),
     LAST_UPDATE_DATE                DATE,
     LAST_UPDATE_LOGIN                        NUMBER(15),
     OBJECT_VERSION_NUMBER           NUMBER,
     START_DATE_ACTIVE		     DATE,
     END_DATE_ACTIVE		     DATE,
     DISB_HEADER_ID		     NUMBER,
     DELETE_DISABLED_FLAG	 	VARCHAR2(1),
     OPEN_PHASE_FLAG			VARCHAR2(1),
     PHASE					VARCHAR2(30)
);

PROCEDURE create_FEE_ASSIGNMENT (
    p_init_msg_list    IN         VARCHAR2,
    p_FEE_ASSIGNMENT_rec   IN         fee_assignment_rec_type,
    x_fee_assignment_id    OUT NOCOPY NUMBER,
    x_return_status    OUT NOCOPY VARCHAR2,
    x_msg_count        OUT NOCOPY NUMBER,
    x_msg_data         OUT NOCOPY VARCHAR2
);

PROCEDURE update_FEE_ASSIGNMENT (
    p_init_msg_list         IN            VARCHAR2,
    p_FEE_ASSIGNMENT_rec        IN            fee_assignment_rec_type,
    p_object_version_number IN OUT NOCOPY NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);

PROCEDURE delete_FEE_ASSIGNMENT (
    p_init_msg_list         IN            VARCHAR2,
    p_fee_assignment_id         IN		  NUMBER,
    x_return_status         OUT NOCOPY    VARCHAR2,
    x_msg_count             OUT NOCOPY    NUMBER,
    x_msg_data              OUT NOCOPY    VARCHAR2
);
/*
PROCEDURE get_FEE_ASSIGNMENT_rec (
    p_init_msg_list   IN         VARCHAR2
    p_fee_assignment_id         IN         NUMBER,
    x_FEE_ASSIGNMENT_rec   OUT NOCOPY fee_assignment_rec_type,
    x_return_status   OUT NOCOPY VARCHAR2,
    x_msg_count       OUT NOCOPY NUMBER,
    x_msg_data        OUT NOCOPY VARCHAR2
);
*/

-- function used to check if any fee assignment exists for a specific fee
-- if so, disallow deletion of that fee in LNS_FEES
FUNCTION IS_EXIST_FEE_ASSIGNMENT (
    p_fee_id			 NUMBER
) RETURN VARCHAR2;


PROCEDURE create_LP_FEE_ASSIGNMENT( P_LOAN_ID NUMBER ) ;

PROCEDURE create_LP_DISB_FEE_ASSIGNMENT( P_DISB_HEADER_ID IN NUMBER, P_LOAN_PRODUCT_LINE_ID IN NUMBER, P_LOAN_ID IN NUMBER ) ;

PROCEDURE delete_DISB_FEE_ASSIGNMENT( P_DISB_HEADER_ID IN NUMBER ) ;

-- function used to check if any fee assignment is editable
function IS_LOAN_FASGM_EDITABLE(p_loan_id           in NUMBER
				,p_fee_id              in NUMBER
				,p_disb_header_id in NUMBER
	    )  return VARCHAR2;


END LNS_FEE_ASSIGNMENT_PUB;

/
