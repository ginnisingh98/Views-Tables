--------------------------------------------------------
--  DDL for Package Body OKC_TASK_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TASK_PUB" AS
  /* $Header: OKCPTSKB.pls 120.0 2005/05/25 18:04:34 appldev noship $ */
	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

 --Procedure to create a task for resolved time value
  PROCEDURE create_task(p_api_version 		IN NUMBER
		       ,p_init_msg_list 	IN VARCHAR2
		       ,p_commit		IN VARCHAR2
		       ,p_resolved_time_id	IN NUMBER
		       ,p_timezone_id		IN NUMBER
		       ,p_timezone_name         IN VARCHAR2
		       ,p_tve_id		IN NUMBER
		       ,p_planned_end_date	IN DATE
		       ,x_return_status   	OUT NOCOPY VARCHAR2
    		       ,x_msg_count       	OUT NOCOPY NUMBER
    		       ,x_msg_data        	OUT NOCOPY VARCHAR2
		       ,x_task_id		OUT NOCOPY NUMBER) IS
	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_task';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--call to private API to create a task for resolved timevalue
	okc_task_pvt.create_task(p_api_version 		=> p_api_version
			        ,p_init_msg_list 	=> p_init_msg_list
			        ,p_resolved_time_id	=> p_resolved_time_id
			        ,p_timezone_id		=> p_timezone_id
			        ,p_timezone_name        => p_timezone_name
			        ,p_tve_id		=> p_tve_id
			        ,p_planned_end_date	=> p_planned_end_date
			        ,x_return_status   	=> x_return_status
    			        ,x_msg_count       	=> x_msg_count
    			        ,x_msg_data        	=> x_msg_data
			        ,x_task_id		=> x_task_id);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
		IF p_commit = 'T' THEN
			commit;
		END IF;
     	END IF;

	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END create_task;

   --Procedure to create a task for condition occurrence
  PROCEDURE create_condition_task(p_api_version 	IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2
			     ,p_cond_occr_id		IN NUMBER
			     ,p_condition_name		IN VARCHAR2
			     ,p_task_owner_id		IN NUMBER
			     ,p_actual_end_date		IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER) IS
	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_condition_task';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--call to private API to create a task for condition occurence
	okc_task_pvt.create_condition_task(p_api_version 	=> p_api_version
			     		  ,p_init_msg_list 	=> p_init_msg_list
			     		  ,p_cond_occr_id	=> p_cond_occr_id
					  ,p_condition_name	=> p_condition_name
					  ,p_task_owner_id	=> p_task_owner_id
			     		  ,p_actual_end_date	=> p_actual_end_date
			     		  ,x_return_status   	=> x_return_status
    			     		  ,x_msg_count       	=> x_msg_count
    			     		  ,x_msg_data        	=> x_msg_data
			     		  ,x_task_id		=> x_task_id);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
		IF p_commit = 'T' THEN
			commit;
		END IF;
     	END IF;

	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END create_condition_task;

  --Procedure to create a task for condition occurence
  PROCEDURE create_contingent_task(p_api_version 	IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2
			     ,p_contract_id		IN NUMBER
			     ,p_contract_number		IN VARCHAR2
			     ,p_contingent_name		IN VARCHAR2
			     ,p_task_owner_id		IN NUMBER
			     ,p_actual_end_date		IN DATE
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2
			     ,x_task_id			OUT NOCOPY NUMBER) IS
	 l_api_name	 CONSTANT VARCHAR2(30) := 'create_contingent_task';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--call to private API to create a task for contingent event
	okc_task_pvt.create_contingent_task(p_api_version 	=> p_api_version
			     		  ,p_init_msg_list 	=> p_init_msg_list
			     		  ,p_contract_id	=> p_contract_id
					  ,p_contract_number	=> p_contract_number
					  ,p_contingent_name	=> p_contingent_name
					  ,p_task_owner_id	=> p_task_owner_id
			     		  ,p_actual_end_date	=> p_actual_end_date
			     		  ,x_return_status   	=> x_return_status
    			     		  ,x_msg_count       	=> x_msg_count
    			     		  ,x_msg_data        	=> x_msg_data
			     		  ,x_task_id		=> x_task_id);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;

          ELSIF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
			IF p_commit = 'T' THEN
				commit;
               END IF;
     	END IF;

	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END create_contingent_task;

  --Procedure to update a task
  PROCEDURE update_task(p_api_version 			IN NUMBER
			     ,p_init_msg_list 		IN VARCHAR2
			     ,p_commit			IN VARCHAR2
			     ,p_object_version_number   IN OUT NOCOPY NUMBER
			     ,p_task_id			IN NUMBER
			     ,p_task_number		IN NUMBER
			     ,p_workflow_process_id	IN NUMBER
			     ,p_actual_end_date       	IN DATE
			     ,p_alarm_fired_count       IN NUMBER
			     ,x_return_status   	OUT NOCOPY VARCHAR2
    			     ,x_msg_count       	OUT NOCOPY NUMBER
    			     ,x_msg_data        	OUT NOCOPY VARCHAR2) IS
	 l_api_name	 CONSTANT VARCHAR2(30) := 'update_task';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--Call to private api to update a task
	okc_task_pvt.update_task(p_api_version 		=> p_api_version
			     ,p_init_msg_list 		=> p_init_msg_list
			     ,p_object_version_number   => p_object_version_number
			     ,p_task_id			=> p_task_id
			     ,p_task_number		=> p_task_number
			     ,p_workflow_process_id	=> p_workflow_process_id
			     ,p_actual_end_date       	=> p_actual_end_date
			     ,p_alarm_fired_count       => p_alarm_fired_count
			     ,x_return_status   	=> x_return_status
    			     ,x_msg_count       	=> x_msg_count
    			     ,x_msg_data        	=> x_msg_data);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
		IF p_commit = 'T' THEN
			commit;
		END IF;
     	END IF;

	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END update_task;

  --Procedure to delete tasks
  PROCEDURE delete_task(p_api_version 			IN NUMBER
		       ,p_init_msg_list 		IN VARCHAR2
		       ,p_commit			IN VARCHAR2
		       ,p_tve_id			IN NUMBER
		       ,p_rtv_id			IN NUMBER
		       ,x_return_status   		OUT NOCOPY VARCHAR2
    		       ,x_msg_count       		OUT NOCOPY NUMBER
    		       ,x_msg_data        		OUT NOCOPY VARCHAR2) IS
	 l_api_name	 CONSTANT VARCHAR2(30) := 'delete_rule_task';
	 l_api_version   CONSTANT NUMBER := 1.0;
    	 l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
	 l_return_status := OKC_API.START_ACTIVITY(l_api_name,
						   g_pkg_name,
						   p_init_msg_list,
					           l_api_version,
						   p_api_version,
						   '_PUB',
                                                   x_return_status);

    	IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    	ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      		RAISE OKC_API.G_EXCEPTION_ERROR;
    	END IF;

	--Call to private api to delete task/s
	okc_task_pvt.delete_task(p_api_version 		=> p_api_version
			     ,p_init_msg_list 		=> p_init_msg_list
			     ,p_tve_id			=> p_tve_id
			     ,p_rtv_id			=> p_rtv_id
			     ,x_return_status   	=> x_return_status
    			     ,x_msg_count       	=> x_msg_count
    			     ,x_msg_data        	=> x_msg_data);
	IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     	ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
       		raise OKC_API.G_EXCEPTION_ERROR;
	ELSIF (x_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
		IF p_commit = 'T' THEN
			commit;
		END IF;
     	END IF;
	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );

    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PUB'
      );
  END delete_task;
END OKC_TASK_PUB;

/
