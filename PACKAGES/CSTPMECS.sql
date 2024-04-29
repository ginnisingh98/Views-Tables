--------------------------------------------------------
--  DDL for Package CSTPMECS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSTPMECS" AUTHID CURRENT_USER AS
/* $Header: CSTMECSS.pls 120.0.12010000.1 2008/07/24 17:21:13 appldev ship $ */
PROCEDURE CSTPALAR (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_USER_ID                   IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE	        OUT NOCOPY 	NUMBER);

PROCEDURE CSTPAPOR (

    I_LIST_ID                   IN        NUMBER,
    I_ORG_ID                    IN        NUMBER,
    I_ACTIVITY_ID               IN        NUMBER,
    I_FROM_DATE                 IN        DATE,
    I_TO_DATE                   IN        DATE,
    I_ACCOUNT_ID                IN        NUMBER,
    I_BASIS_TYPE                IN        NUMBER,
    I_FIXED_RATE                IN        NUMBER,
    I_PER_INC                   IN        NUMBER,
    I_AMT_INC                   IN        NUMBER,
    I_COST_TYPE_ID              IN        NUMBER,
    I_COPY_COST_TYPE            IN        NUMBER,
    I_RESOURCE_ID               IN        NUMBER,

    I_USER_ID                   IN        NUMBER,
    I_REQUEST_ID                IN        NUMBER,
    I_PROGRAM_ID                IN        NUMBER,
    I_PROGRAM_APPL_ID           IN        NUMBER,

    O_RETURN_CODE               IN OUT NOCOPY    NUMBER);

PROCEDURE CSTPAWAC (

    I_LIST_ID                   IN        NUMBER,
    I_ORG_ID                    IN        NUMBER,
    I_ACTIVITY_ID               IN        NUMBER,
    I_FROM_DATE                 IN        DATE,
    I_TO_DATE                   IN        DATE,
    I_ACCOUNT_ID                IN        NUMBER,
    I_BASIS_TYPE                IN        NUMBER,
    I_FIXED_RATE                IN        NUMBER,
    I_PER_INC                   IN        NUMBER,
    I_AMT_INC                   IN        NUMBER,
    I_COST_TYPE_ID              IN        NUMBER,
    I_COPY_COST_TYPE            IN        NUMBER,
    I_RESOURCE_ID               IN        NUMBER,

    I_USER_ID                   IN        NUMBER,
    I_REQUEST_ID                IN        NUMBER,
    I_PROGRAM_ID                IN        NUMBER,
    I_PROGRAM_APPL_ID           IN        NUMBER,

    O_RETURN_CODE               IN OUT NOCOPY    NUMBER);


PROCEDURE CSTPOPOA (

    I_LIST_ID                   IN      NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID               IN      NUMBER,
    I_FROM_DATE                 IN      DATE,
    I_TO_DATE                   IN      DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_USER_ID                   IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE               IN OUT NOCOPY  NUMBER);

PROCEDURE CSTPSHRK (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE	        OUT NOCOPY 	NUMBER);

PROCEDURE CSTPSMOH (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE	        OUT NOCOPY 	NUMBER);

PROCEDURE CSTPSMTL (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE	        OUT NOCOPY 	NUMBER);

PROCEDURE CSTPSPSR (

    I_LIST_ID 			IN	NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID		IN	NUMBER,
    I_FROM_DATE		        IN	DATE,
    I_TO_DATE		        IN	DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_LAST_UPDATED_BY           IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE	        OUT NOCOPY 	NUMBER);

PROCEDURE CSTPULMC (

    I_LIST_ID                   IN      NUMBER,
    I_ORG_ID                    IN      NUMBER,
    I_ACTIVITY_ID               IN      NUMBER,
    I_FROM_DATE                 IN      DATE,
    I_TO_DATE                   IN      DATE,
    I_ACCOUNT_ID                IN      NUMBER,
    I_BASIS_TYPE                IN      NUMBER,
    I_FIXED_RATE                IN      NUMBER,
    I_PER_INC                   IN      NUMBER,
    I_AMT_INC                   IN      NUMBER,
    I_COST_TYPE_ID              IN      NUMBER,
    I_COPY_COST_TYPE            IN      NUMBER,
    I_RESOURCE_ID               IN      NUMBER,

    I_USER_ID                   IN      NUMBER,
    I_REQUEST_ID                IN      NUMBER,
    I_PROGRAM_ID                IN      NUMBER,
    I_PROGRAM_APPL_ID           IN      NUMBER,

    O_RETURN_CODE               IN OUT NOCOPY         NUMBER);

END CSTPMECS;

/
