--------------------------------------------------------
--  DDL for Package INV_CG_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_CG_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: INVCGUGS.pls 120.1 2005/06/15 15:06:05 appldev  $ */
PROCEDURE INVMSISB(
		   l_organization_id 	IN  	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		    x_msg_data        	OUT NOCOPY 	VARCHAR2);


PROCEDURE INVMPSSB(
                   l_organization_id   IN      NUMBER,
		   p_cost_method	IN	NUMBER,
                   USER_NAME           IN      VARCHAR2,
		   PASSWORD            IN      VARCHAR2,
                   x_return_status     OUT NOCOPY     VARCHAR2,
                   x_msg_count         OUT NOCOPY     NUMBER,
                   x_msg_data          OUT NOCOPY     VARCHAR2);


PROCEDURE INVMPSB(
		  l_organization_id   IN      NUMBER,
		  USER_NAME           IN      VARCHAR2,
		  PASSWORD            IN      VARCHAR2,
		  x_return_status     OUT NOCOPY     VARCHAR2,
		  x_msg_count         OUT NOCOPY     NUMBER,
		  x_msg_data          OUT NOCOPY     VARCHAR2);


PROCEDURE INVMOQSB(
		   l_organization_id   IN  	NUMBER,
		   p_cost_method	IN	NUMBER,
		   USER_NAME           IN      VARCHAR2,
  		   PASSWORD            IN      VARCHAR2,
		   x_return_status     OUT NOCOPY 	VARCHAR2,
		   x_msg_count         OUT NOCOPY 	NUMBER,
		   x_msg_data          OUT NOCOPY 	VARCHAR2);



PROCEDURE INVMMTSB(
		   l_organization_id 	IN  	NUMBER,
		   p_cost_method	IN	NUMBER,
		   p_open_periods_only   IN	NUMBER,
		   USER_NAME           IN      VARCHAR2,
		   PASSWORD            IN      VARCHAR2,
		   x_return_status	  	OUT NOCOPY 	VARCHAR2,
		   x_msg_count       	OUT NOCOPY 	NUMBER,
		   x_msg_data        	OUT NOCOPY 	VARCHAR2);




PROCEDURE INS_ERROR (
		      p_table_name         IN   VARCHAR2,
		      p_ROWID  	   IN  	VARCHAR2,
		      p_org_id             IN   NUMBER,
		      p_error_msg	   IN   VARCHAR2,
                      p_proc_name          IN   VARCHAR2
		    );

PROCEDURE LAUNCH_UPGRADE(p_open_periods_only	IN	NUMBER default 1) ;


PROCEDURE INVMCCESB (
		     l_organization_id 	IN  	NUMBER,
		    p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		     x_msg_data        	OUT NOCOPY 	VARCHAR2
		     );


PROCEDURE INVMPASB (
                    l_organization_id 	IN  	NUMBER,
		    p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		     x_msg_data        	OUT NOCOPY 	VARCHAR2

		    );


PROCEDURE INVMPITSB (
                    l_organization_id 	IN  	NUMBER,
		    p_cost_method	IN	NUMBER,
		    USER_NAME           IN      VARCHAR2,
		    PASSWORD            IN      VARCHAR2,
		    x_return_status	OUT NOCOPY 	VARCHAR2,
		    x_msg_count       	OUT NOCOPY 	NUMBER,
		     x_msg_data        	OUT NOCOPY 	VARCHAR2

		    );

  --      Name: CG_UPGR_FOR_CLOSED_PER_CP
  --
  --      Input parameters: None
  --
  --      Output parameters:
  --                  x_errorbuf  -> Message text buffer
  --                  x_retcode   -> Error Return code
  --
  --      Functions: This API is used in the concurrent program
  --                 'Costgroup upgrade for closed periods'.
  --                 This API inturn calls INV_CG_UPGRADE.LAUNCH_UPGRADE()
  --                 with input parameter 2 to include transactions
  --                 from closed periods for Cost Group Upgrade.

PROCEDURE CG_UPGR_FOR_CLOSED_PER_CP(
                x_errorbuf         OUT NOCOPY  VARCHAR2
              , x_retcode          OUT NOCOPY  VARCHAR2);

END inv_cg_upgrade;

 

/
