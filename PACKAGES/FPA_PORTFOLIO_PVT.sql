--------------------------------------------------------
--  DDL for Package FPA_PORTFOLIO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FPA_PORTFOLIO_PVT" AUTHID CURRENT_USER as
/* $Header: FPAVPTFS.pls 120.1 2005/08/18 11:47:23 appldev noship $ */

TYPE portfolio_rec_type IS RECORD
(

    portfolio_id            VARCHAR2(30),
    portfolio_name          VARCHAR2(55),
    portfolio_desc          VARCHAR2(240),
    Portfolio_owner_id      VARCHAR2(30),
    portfolio_type          VARCHAR2(30),
    Portfolio_start_org_id  Varchar2(30)
);


   PROCEDURE Create_Portfolio
     (
    	p_api_version		IN		NUMBER,
	    p_portfolio_rec		IN		FPA_Portfolio_PVT.portfolio_rec_type,
	    x_portfolio_id	    OUT NOCOPY	VARCHAR2,
	    x_return_status		OUT NOCOPY	VARCHAR2,
	    x_msg_data			OUT NOCOPY	VARCHAR2,
	    x_msg_count			OUT NOCOPY	NUMBER
	);

  PROCEDURE Delete_Portfolio
     (
       p_api_version		IN		    NUMBER,
       p_portfolio_id       IN          NUMBER,
       x_return_status		OUT NOCOPY	VARCHAR2,
	   x_msg_data			OUT NOCOPY	VARCHAR2,
	   x_msg_count			OUT NOCOPY	NUMBER
    ) ;


   PROCEDURE Upadate_Portfolio_Descr
        (
	    p_api_version		IN		NUMBER,
	    p_portfolio_rec		IN		FPA_Portfolio_PVT.portfolio_rec_type,
	    x_return_status		OUT NOCOPY	VARCHAR2,
	    x_msg_data			OUT NOCOPY	VARCHAR2,
	    x_msg_count			OUT NOCOPY	NUMBER
	    );

    PROCEDURE Upadate_Portfolio_type
        (
        p_api_version		    IN		NUMBER,
  	    p_portfolio_id          IN      NUMBER,
  	    p_portfolio_class_code	IN		NUMBER,
	    x_return_status		    OUT NOCOPY	VARCHAR2,
	    x_msg_data			    OUT NOCOPY	VARCHAR2,
	    x_msg_count			    OUT NOCOPY	NUMBER
	    );

      PROCEDURE Upadate_Portfolio_organization
        (
	    p_api_version		        IN		NUMBER,
	    p_portfolio_id              IN      NUMBER,
  	    p_portfolio_organization	IN		NUMBER,
	    x_return_status		        OUT NOCOPY	VARCHAR2,
	    x_msg_data			        OUT NOCOPY	VARCHAR2,
	    x_msg_count			        OUT NOCOPY	NUMBER
	    );



   FUNCTION Check_Portfolio_name
     (
       p_api_version		IN		    NUMBER,
       p_portfolio_id       IN          NUMBER,
       p_portfolio_name		IN		    VARCHAR2,
	   x_return_status		OUT NOCOPY	VARCHAR2,
	   x_msg_data			OUT NOCOPY	VARCHAR2,
	   x_msg_count			OUT NOCOPY	NUMBER
    ) RETURN NUMBER;





END; -- Package spec

 

/
