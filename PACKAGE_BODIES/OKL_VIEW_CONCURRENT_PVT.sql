--------------------------------------------------------
--  DDL for Package Body OKL_VIEW_CONCURRENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VIEW_CONCURRENT_PVT" AS
/* $Header: OKLRVCPB.pls 115.3 2002/12/18 12:52:11 kjinger noship $ */

PROCEDURE Get_Url_Diagnostics_Text
				(p_api_version      IN  NUMBER
                 ,p_init_msg_list   IN  VARCHAR2
                 ,x_return_status   OUT NOCOPY VARCHAR2
                 ,x_msg_count       OUT NOCOPY NUMBER
                 ,x_msg_data        OUT NOCOPY VARCHAR2
	             ,p_request_id      IN  NUMBER
	             ,p_log_url		    OUT NOCOPY VARCHAR2
	             ,p_output_url	    OUT NOCOPY VARCHAR2
	             ,p_diagnostices OUT NOCOPY VARCHAR2)
IS
   l_log_url 		VARCHAR2(4000);
   l_output_url 	VARCHAR2(4000);
   l_file_type 		NUMBER;
   l_phase 	   		VARCHAR2(80);
   l_status    		VARCHAR2(80);
   l_help_text 		VARCHAR2(4000);


BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

-- Get the URL for log  file

    l_file_type := 3;
    l_log_url := Fnd_Webfile.get_url(
               file_type  	=> l_file_type,
               id  			=> p_request_id,
               gwyuid 		=> fnd_profile.value('GWYUID'),
               two_task 	=> fnd_profile.value('TWO_TASK'),
               expire_time 	=> 10);

    IF l_log_url IS NOT NULL THEN
        p_log_url := l_log_url;
    ELSE
        p_log_url := 'N';
    END IF;

-- Get the URL for output  file

    l_file_type := 4;
    l_output_url := Fnd_Webfile.get_url(
               file_type  	=> l_file_type,
               id  			=> p_request_id,
               gwyuid 		=> fnd_profile.value('GWYUID'),
               two_task 	=> fnd_profile.value('TWO_TASK'),
               expire_time 	=> 10);

    IF l_output_url IS NOT NULL THEN
       p_output_url := l_output_url;
    ELSE
       p_output_url := 'N';
    END IF;

-- Get the Diagnostics Text for the Request ID

    fnd_conc.diagnose (
		     request_id => p_request_id,
		     phase => l_phase,
		     status => l_status,
		     help_text => l_help_text);

	p_diagnostices	:= l_help_text;

EXCEPTION
      WHEN OTHERS THEN
        IF  p_output_url IS NULL THEN
	    p_output_url	:= 'N';
	END IF;

END Get_Url_Diagnostics_Text;

END OKL_VIEW_CONCURRENT_PVT;

/
