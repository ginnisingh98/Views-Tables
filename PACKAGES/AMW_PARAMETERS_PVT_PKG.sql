--------------------------------------------------------
--  DDL for Package AMW_PARAMETERS_PVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMW_PARAMETERS_PVT_PKG" AUTHID CURRENT_USER as
/*$Header: amwparps.pls 120.1 2005/10/25 23:25:31 appldev noship $*/
PROCEDURE insert_parameter(
      p_parameter_name IN VARCHAR2,
      p_parameter_value IN VARCHAR2,
      p_pk1 IN VARCHAR2,
      p_pk2 IN VARCHAR2,
      p_pk3 IN VARCHAR2,
      p_pk4 IN VARCHAR2,
      p_pk5 IN VARCHAR2);

PROCEDURE update_parameter(
      p_parameter_name in varchar2,
      p_parameter_value in varchar2,
      p_pk1 in varchar2,
      p_pk2 in varchar2,
      p_pk3 in varchar2,
      p_pk4 in varchar2,
      p_pk5 in varchar2);

PROCEDURE initialize_org_parameters(
p_process_approval_option IN VARCHAR2,
p_process_auto_approve IN VARCHAR2,
p_pk1 IN VARCHAR2,
p_pk2 IN VARCHAR2 := NULL,
p_pk3 IN VARCHAR2 := NULL,
p_pk4 IN VARCHAR2 := NULL,
p_pk5 IN VARCHAR2 := NULL,
p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		   OUT NOCOPY VARCHAR2,
x_msg_count                  OUT NOCOPY VARCHAR2,
x_msg_data		    OUT NOCOPY VARCHAR2
 );

PROCEDURE update_org_parameters(
p_process_approval_option IN VARCHAR2,
p_process_auto_approve IN VARCHAR2,
p_pk1 IN VARCHAR2,
p_pk2 IN VARCHAR2 := NULL,
p_pk3 IN VARCHAR2 := NULL,
p_pk4 IN VARCHAR2 := NULL,
p_pk5 IN VARCHAR2 := NULL,
p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		   OUT NOCOPY VARCHAR2,
x_msg_count                  OUT NOCOPY VARCHAR2,
x_msg_data		    OUT NOCOPY VARCHAR2
 );

procedure load_initial_seed_data (p_PARAMETER_NAME in varchar2,
				  p_parameter_value in varchar2,
				  p_pk1 in varchar2,
				  p_pk2 in varchar2,
				  p_pk3 in varchar2,
				  p_pk4 in varchar2,
				  p_pk5 in varchar2,
				  x_owner in varchar2,
				  x_last_update_date in varchar2);

--kosriniv..for bug fix..4336520
PROCEDURE default_org_parameters(
p_org IN VARCHAR2,
p_commit		           IN VARCHAR2 := FND_API.G_FALSE,
p_validation_level		   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
p_init_msg_list		   IN VARCHAR2 := FND_API.G_FALSE,
x_return_status		   OUT NOCOPY VARCHAR2,
x_msg_count                  OUT NOCOPY VARCHAR2,
x_msg_data		    OUT NOCOPY VARCHAR2
 );


-- kosriniv ..update orgs concurrent programs
PROCEDURE update_all_org_params_cp(
errbuf     out nocopy  varchar2,
retcode    out nocopy  varchar2,
p_proc_approval_option in varchar2, -- A,B,C..
p_approval_required in varchar2, -- Y/N ..Y means auto_approve is No and N means auto_approve is Yes.
p_all_orgs in varchar2  -- NOCONF means only orgs that have not been configured..ALL means set/update all the orgs..
);
END AMW_PARAMETERS_PVT_PKG;

 

/
