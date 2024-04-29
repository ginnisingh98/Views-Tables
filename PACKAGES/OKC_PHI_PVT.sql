--------------------------------------------------------
--  DDL for Package OKC_PHI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_PHI_PVT" AUTHID CURRENT_USER AS
/* $Header: OKCRPHIS.pls 120.0 2005/05/26 09:56:49 appldev noship $ */

--
-- Global constants
--
-------------------------------------------------------------------------------------------------------------------------
-- Procedure : Process_price_hold
--  Input Parameter : p_chr_id Contract Id of contract which has price hold on it.
--                    P_opreation_code   Possible value UPDATE and TERMINATE
--                    P_termination_date
--
-- If this API is called for a contract for the first time with operation UPDATE then it creates a Modifier and Pricing Agreement in QP.
--
-- If this API is called for a contract for the another time with operation UPDATE then it updates a Modifier and Pricing Agreement
-- in QP and creates new Modifier line if new liens have been added to contract.
--
-- If this API is called for a contract with operation TERMINATE then it de-activates a Modifier and Pricing Agreement in QP.

-- This API will be called whenever a contract/contract line is activated or Terminated or cancelled.
--------------------------------------------------------------------------------------------------------------------------------

PROCEDURE process_price_hold(p_api_version    IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                            ,p_init_msg_list  IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                            ,p_chr_id         IN OKC_K_HEADERS_V.id%TYPE   -- Price Hold Contract Id
                            ,p_operation_code IN VARCHAR2                  -- Operation UPDATE/TERMINATE
 			    ,p_termination_date IN DATE
 			    ,p_unconditional_call IN varchar2 Default 'N'
                            ,x_return_status  OUT NOCOPY VARCHAR2
                            ,x_msg_count      OUT NOCOPY NUMBER
                            ,x_msg_data       OUT NOCOPY VARCHAR2
                            );

-------------------------------------------------------------------------------------------------------------------------
--Procedure : extend_price_hold
--  Input Parameter : p_cle_id Contract Line Id of price hold topline.
--
-- This API is called whenever a price hold line is extended.What it does is that it extends
-- modifier,modifier line and price agreements in QP
--
---------------------------------------------------------------------------------------------------------------------------------

PROCEDURE extend_price_hold(p_api_version   IN NUMBER   DEFAULT OKC_API.G_MISS_NUM
                           ,p_init_msg_list IN VARCHAR2 DEFAULT OKC_API.G_FALSE
                           ,p_cle_id       IN OKC_K_LINES_V.id%TYPE   -- Price Hold Topline Id
                           ,x_return_status OUT NOCOPY VARCHAR2
                           ,x_msg_count     OUT NOCOPY NUMBER
                           ,x_msg_data      OUT NOCOPY VARCHAR2
                            );

-------------------------------------------------------------------------------------------------------------------------
--Procedure : COPY_LINES
--  Input Parameter : p_cle_id - Contract Line Id of price hold topline.
--                    p_chr_id - Contract Header ID
--                    p_delete_before_yn - delete current lines before copying
--                    p_commit_changes_yn - commit changes after copying
--
-- This procedure copies Not Price Hold contract lines as sublines for Price Hold TopLine.
---------------------------------------------------------------------------------------------------------------------------------
PROCEDURE COPY_LINES(
             p_api_version	IN	NUMBER,
             p_init_msg_list	IN	VARCHAR2 default OKC_API.G_FALSE,
             x_return_status	OUT NOCOPY	VARCHAR2,
             x_msg_count	OUT NOCOPY	NUMBER,
             x_msg_data	OUT NOCOPY	VARCHAR2,
             p_chr_id IN NUMBER,  -- Contract Header ID
             p_cle_id in number,  -- Price Hold TopLine ID
             p_restricted_update in VARCHAR2,
             p_delete_before_yn in VARCHAR2 DEFAULT 'N',-- delete current lines before copying
             p_commit_changes_yn in VARCHAR2 DEFAULT 'N', -- commit changes after copying
             x_recs_copied OUT NOCOPY NUMBER);

END OKC_PHI_PVT;

 

/
