--------------------------------------------------------
--  DDL for Package Body OKL_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_WF_PVT" AS
/* $Header: OKLRCWFB.pls 120.4 2005/10/30 04:02:27 appldev noship $ */


  G_WF_ITM_USER_ID CONSTANT VARCHAR2(15) := 'USER_ID';
  G_WF_ITM_EVENT_DATE CONSTANT VARCHAR2(15) := 'EVENT_DATE';
  G_WF_ITM_EVENT_NAME CONSTANT VARCHAR2(15) := 'EVENT_NAME';


  FUNCTION check_batch_process
  RETURN BOOLEAN
  IS
   l_request_id NUMBER;
   l_ret_value BOOLEAN := FALSE;
  BEGIN
  	   -- Check for Request ID and return true if found
      SELECT Fnd_Global.CONC_REQUEST_ID
      INTO   l_request_id
      FROM DUAL;

	  IF (l_request_id <> -1) THEN
	  	  l_ret_value := TRUE;
	  END IF;

	  RETURN l_ret_value;
  END check_batch_process;

  FUNCTION check_batch_process_enabled
  RETURN BOOLEAN
  IS
   l_profile_value VARCHAR2(1);
   l_ret_value BOOLEAN := FALSE;
  BEGIN

	   l_profile_value := fnd_profile.value('OKL_ENABLE_EVENTS_FOR_BATCH');

	   IF l_profile_value = 'Y' THEN
	    l_ret_value := TRUE;
	   END IF;

	   RETURN l_ret_value;
  END check_batch_process_enabled;

  ---------------------------------------------------------------------------
  -- FUNCTION get_event_key
  ---------------------------------------------------------------------------
  FUNCTION get_event_key RETURN VARCHAR2 IS
    l_newvalue NUMBER := 1;
  BEGIN
	SELECT OKL_WF_ITEM_S.NEXTVAL INTO	l_newvalue FROM dual;
    RETURN(TO_CHAR(l_newvalue));
  END get_event_key;

  PROCEDURE raise_event (p_api_version    IN  NUMBER,
                         p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                         x_return_status  OUT NOCOPY VARCHAR2,
                         x_msg_count      OUT NOCOPY NUMBER,
                         x_msg_data       OUT NOCOPY VARCHAR2,
                         p_event_name     IN VARCHAR2,
                         p_event_key     IN VARCHAR2 DEFAULT NULL,
                         p_event_data IN clob DEFAULT NULL,
                         p_parameters IN wf_parameter_list_t DEFAULT NULL,
                         p_send_date  IN DATE DEFAULT NULL,
                         p_include_user_params IN VARCHAR2 DEFAULT OKL_API.G_TRUE)
  IS

    l_api_name                        CONSTANT VARCHAR2(30)  := 'raise_event';
    l_api_version      CONSTANT NUMBER       := 1.0;
	l_return_status VARCHAR2(1) := G_RET_STS_SUCCESS;

    l_raise_event BOOLEAN := FALSE;
    l_parameter_list           wf_parameter_list_t := p_parameters;
	l_event_key VARCHAR2(1000) := p_event_key;

  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(p_api_name       => l_api_name,
                                              p_pkg_name	   => G_PKG_NAME,
                                              p_init_msg_list  => p_init_msg_list,
                                              l_api_version	   => l_api_version,
                                              p_api_version	   => p_api_version,
                                              p_api_type	   => G_API_TYPE,
                                              x_return_status  => l_return_status);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_ERROR;
    END IF;

    l_raise_event := TRUE;

    	IF check_batch_process THEN
    		IF check_batch_process_enabled THEN
    		   l_raise_event := TRUE;
	    	ELSE
    		  l_raise_event := FALSE;
    		END IF;
    	END IF;

    	IF l_raise_event  THEN
    		IF (p_include_user_params = OKL_API.G_TRUE) THEN

			  Wf_Event.AddParameterToList(G_WF_ITM_USER_ID,FND_GLOBAL.USER_ID,l_parameter_list);
			  Wf_Event.AddParameterToList(G_WF_ITM_EVENT_DATE,fnd_date.date_to_canonical(SYSDATE),l_parameter_list);
                          Wf_Event.AddParameterToList(G_WF_ITM_EVENT_NAME,p_event_name,l_parameter_list);

    		 END IF;

			 IF l_event_key IS NULL THEN
                   l_event_key := get_event_key;
			 END IF;

		     -- Raise Event
		     Wf_Event.RAISE(p_event_name => p_event_name,
                            p_event_key => l_event_key,
		                    p_parameters => l_parameter_list);

		     l_parameter_list.DELETE;

    	END IF;

    Okl_Api.END_ACTIVITY(x_msg_count  => x_msg_count
                        ,x_msg_data   => x_msg_data);

    x_return_status := l_return_status;


  EXCEPTION
    WHEN G_EXCEPTION_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

    WHEN G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_UNEXP_ERROR,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);
    WHEN OTHERS THEN

      x_return_status := Okl_Api.HANDLE_EXCEPTIONS(p_api_name	=> l_api_name,
                                                   p_pkg_name	=> G_PKG_NAME,
                                                   p_exc_name   => G_EXC_NAME_OTHERS,
                                                   x_msg_count	=> x_msg_count,
                                                   x_msg_data	=> x_msg_data,
                                                   p_api_type	=> G_API_TYPE);

  END raise_event;



END OKL_WF_PVT;

/
