--------------------------------------------------------
--  DDL for Package Body PA_EGO_WRAPPER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_EGO_WRAPPER_PUB" AS
 /* $Header: PAEGOWPB.pls 120.2 2006/01/12 01:52:25 msachan noship $   */

l_pkg_name    VARCHAR2(30) := 'PA_EGO_WRAPPER_PUB';


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_phase_ok(
	p_api_version			IN	NUMBER   :=1.0			,
	p_phase_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 := NULL		,
	x_delete_ok			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_errorcode			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2  -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'check_delete_phase_ok';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

	l_phase_id		      NUMBER;
        l_delete_ok                   VARCHAR2(1);
BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_delete_ok     := FND_API.G_FALSE;

	EGO_LIFECYCLE_ADMIN_PUB.check_delete_phase_ok(
		p_api_version		=> p_api_version	,
		p_phase_id		=> p_phase_id		,
		p_init_msg_list		=> p_init_msg_list	,
		x_delete_ok		=> l_delete_ok		,
		x_return_status		=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data );

/* Bug 2760719 -- Added check for l_delete_ok  <> FND_API.G_TRUE and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_delete_ok  <> FND_API.G_TRUE OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
     		If l_msg_count > 0 THEN
		     x_msg_count := l_msg_count;
		     If l_msg_count = 1 THEN
		             pa_interface_utils_pub.get_messages
				 (p_encoded        => FND_API.G_TRUE		,
			          p_msg_index      => 1				,
			          p_msg_count      => l_msg_count		,
			          p_msg_data       => l_msg_data		,
			          p_data           => l_data			,
			          p_msg_index_out  => l_msg_index_out
				  );
			    x_msg_data := l_data;
		     End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	END IF;
x_errorcode          := l_errorcode;
x_return_status      := l_return_status;
x_delete_ok          := l_delete_ok;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_phase_ok',
                            p_error_text     => x_msg_data);

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_phase_ok',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_phase_ok',
                            p_error_text     => x_msg_data);
    raise;
END check_delete_phase_ok;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE process_phase_delete(
	p_api_version	IN	NUMBER	:= 1.0		,
	p_phase_id 	IN	NUMBER			,
	p_init_msg_list	IN	VARCHAR2 := NULL	,
	p_commit       	IN	VARCHAR2 := NULL	,
	x_errorcode   	OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_return_status	OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_msg_count	OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_data	OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'process_phase_delete';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

	l_lifecycle_phase_id	      NUMBER;
	BEGIN

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT wrapper_process_phase_delete;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

	EGO_LIFECYCLE_ADMIN_PUB.process_phase_delete(
		p_api_version		=> p_api_version	,
		p_phase_id		=> p_phase_id		,
		p_init_msg_list		=> p_init_msg_list	,
		p_commit		=> p_commit		,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_return_status 	=> l_return_status	,
		x_msg_data		=> l_msg_data
		);

/* Bug 2760719 -- Added check for l_return_status  <> FND_API.G_RET_STS_SUCCESS and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
		    x_msg_count := l_msg_count;
	          If l_msg_count = 1 THEN
		     pa_interface_utils_pub.get_messages
			 (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		  End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	END IF;

x_errorcode          := l_errorcode;
x_return_status      := l_return_status;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
        COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_process_phase_delete;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'process_phase_delete',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'process_phase_delete',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_process_phase_delete;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_process_phase_delete;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'process_phase_delete',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END process_phase_delete;



	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_lifecycle_ok(
	p_api_version			IN	NUMBER	:= 1.0			,
	p_lifecycle_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 := NULL		,
	x_delete_ok			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_errorcode			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'check_delete_lifecycle_ok';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

	l_lifecycle_id		      NUMBER;
	l_delete_ok		      VARCHAR2(1);
BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_delete_ok     := FND_API.G_FALSE;

	EGO_LIFECYCLE_ADMIN_PUB.check_delete_lifecycle_ok(
		p_api_version		=> p_api_version	,
		p_lifecycle_id		=> p_lifecycle_id	,
		p_init_msg_list		=> p_init_msg_list	,
		x_delete_ok		=> l_delete_ok		,
		x_return_status		=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data );

/* Bug 2760719 -- Added check for l_delete_ok  <> FND_API.G_TRUE and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_delete_ok  <> FND_API.G_TRUE OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;
x_errorcode          := l_errorcode;
x_return_status      := l_return_status;
x_delete_ok	     := l_delete_ok;


EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_lifecycle_ok',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_lifecycle_ok',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_lifecycle_ok',
                            p_error_text     =>  x_msg_data);
    raise;
END check_delete_lifecycle_ok;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/


PROCEDURE delete_stale_data_for_lc(
	p_api_version			IN NUMBER := 1.0			,
	p_lifecycle_id 			IN NUMBER				,
	p_init_msg_list			IN VARCHAR2 := NULL			,
	p_commit       			IN VARCHAR2 := NULL			,
	x_errorcode   			OUT NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_return_status			OUT NOCOPY VARCHAR2				, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)

IS
	l_api_name	     CONSTANT VARCHAR(30) := 'delete_stale_data_for_lc';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

	l_lifecycle_id	      NUMBER;
	BEGIN

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT wrapper_delete_data_for_lc;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

	EGO_LIFECYCLE_ADMIN_PUB.delete_stale_data_for_lc(
		p_api_version		=> p_api_version	,
		p_lifecycle_id		=> p_lifecycle_id	,
		p_init_msg_list		=> p_init_msg_list	,
		p_commit		=> p_commit		,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_return_status 	=> l_return_status	,
		x_msg_data		=> l_msg_data
		);

/* Bug 2760719 -- Added check for l_return_status  <> FND_API.G_RET_STS_SUCCESS and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;

x_errorcode          := l_errorcode;
x_return_status      := l_return_status;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
        COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_delete_data_for_lc;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'delete_stale_data_for_lc',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'delete_stale_data_for_lc',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_delete_data_for_lc;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_delete_data_for_lc;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'delete_stale_data_for_lc',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END delete_stale_data_for_lc;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/



PROCEDURE get_policy_for_phase_change(
	p_api_version			IN	NUMBER	:= 1.0			,
        p_project_id                    IN      NUMBER                          , -- Bug 2800909
	p_current_phase_id		IN	NUMBER				,
	p_future_phase_id		IN	NUMBER				,
	p_phase_change_code		IN	VARCHAR2			,
	p_lifecycle_id			IN	NUMBER				,
	x_policy_code			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_error_message			OUT	NOCOPY VARCHAR2			, -- Bug 2760719 -- NOCOPY change for Bug 4939368
	x_errorcode			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2			 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'get_policy_for_phase_change';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;
	l_policy_code		      VARCHAR2(30);
	l_error_message		      VARCHAR2(32);	-- Bug 2760719

BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_policy_code   := 'NOT_ALLOWED';

	EGO_LIFECYCLE_USER_PUB.get_policy_for_phase_change(
		p_api_version		=> p_api_version	,
		p_project_id            => p_project_id         ,  -- Bug 2800909
		p_curr_phase_id		=> p_current_phase_id	,
		p_future_phase_id	=> p_future_phase_id	,
		p_phase_change_code	=> p_phase_change_code	,
		p_lifecycle_id		=> p_lifecycle_id	,
		x_policy_code		=> l_policy_code	,
		x_error_message		=> l_error_message	, -- Bug 2760719
		x_return_status		=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data );

-- Note that raising and population of error messages is not done here. It is the calling api's
-- responsibility to put the error messahe into stack if required.

x_errorcode	     := l_errorcode;
x_error_message	     :=	l_error_message;
x_return_status      := l_return_status;
x_policy_code	     := l_policy_code;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_policy_code   := 'NOT_ALLOWED';              -- NOCOPY change for Bug 4939368
    x_error_message := SQLERRM;                    -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'get_policy_for_phase_change',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_policy_code   := 'NOT_ALLOWED';              -- NOCOPY change for Bug 4939368
    x_error_message := SQLERRM;                    -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'get_policy_for_phase_change',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_policy_code   := 'NOT_ALLOWED';              -- NOCOPY change for Bug 4939368
    x_error_message := SQLERRM;                    -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'get_policy_for_phase_change',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END get_policy_for_phase_change;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE sync_phase_change(
	p_api_version			IN	NUMBER	:=1.0			,
	p_project_id    		IN	NUMBER				,
	p_lifecycle_id 			IN	NUMBER				,
	p_phase_id 			IN	NUMBER				,
	p_effective_date		IN	DATE				,
	p_init_msg_list			IN	VARCHAR2 := NULL		,
	p_commit       			IN	VARCHAR2 := NULL		,
	x_errorcode   			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'sync_phase_change';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

BEGIN
	IF(p_commit = FND_API.G_TRUE) THEN
		  SAVEPOINT wrapper_sync_phase_change;
	END IF;

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

	EGO_LIFECYCLE_USER_PUB.sync_phase_change(
		p_api_version		=> p_api_version	,
		p_project_id		=> p_project_id		,
		p_lifecycle_id		=> p_lifecycle_id	,
		p_phase_id		=> p_phase_id		,
		p_effective_date	=> p_effective_date	,
		p_init_msg_list		=> p_init_msg_list	,
		p_commit		=> p_commit		,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_return_status 	=> l_return_status	,
		x_msg_data		=> l_msg_data );

/* Bug 2760719 -- Added check for l_return_status  <> FND_API.G_RET_STS_SUCCESS and moved raise statement
                  outside the IF l_msg_count > 0 */
/*** Commented for bug 4049700 the code as this is calling the pa_interface_utils_pub.get_messages
even if the l_msg_count is returned as 1

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	END IF;
***/

/** Added for 4049700 **/
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
	   IF NVL(l_msg_count,0) = 1 THEN
	     x_return_status   := l_return_status;
	     x_msg_count       := l_msg_count;
	     x_msg_data        := l_msg_data;
             IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
		FND_MESSAGE.SET_NAME('PA','PA_SHOW_EGO_ERROR');
		FND_MESSAGE.SET_TOKEN('ERROR_TEXT',l_msg_data);
		FND_MSG_PUB.add;
      	     END IF;
	     RAISE  FND_API.G_EXC_ERROR;
	   ELSE
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
		  x_msg_count := l_msg_count;
		     pa_interface_utils_pub.get_messages
			 (p_encoded        => FND_API.G_TRUE		,
			  p_msg_index      => 1				,
			  p_msg_count      => l_msg_count		,
			  p_msg_data       => l_msg_data		,
			  p_data           => l_data			,
			  p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		End if;
		RAISE  FND_API.G_EXC_ERROR;
	   END IF;
      END IF;
/** End for 4049700 **/

x_errorcode	     := l_errorcode;
x_return_status      := l_return_status;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
        COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
	IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
	      ROLLBACK TO wrapper_sync_phase_change;
	END IF;

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'sync_phase_change',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
	IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
	      ROLLBACK TO wrapper_sync_phase_change;
	END IF;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'sync_phase_change',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

	/* Added for 4049700 */
        RAISE;
	/** End for 4049700 **/

WHEN OTHERS THEN

	IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
	      ROLLBACK TO wrapper_sync_phase_change;
	END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'sync_phase_change',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END sync_phase_change;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_lc_tracking_project(
	p_api_version			IN	NUMBER	:= 1.0			,
	p_project_id			IN	NUMBER				,
	x_is_lifecycle_tracking		OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_errorcode			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'check_lc_tracking_project';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;
	l_is_lifecycle_tracking	      VARCHAR2(30);

BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status		  := FND_API.G_RET_STS_SUCCESS;
	x_is_lifecycle_tracking   := FND_API.G_TRUE;


	EGO_LIFECYCLE_USER_PUB.check_lc_tracking_project(
		p_api_version		=> p_api_version		,
		p_project_id		=> p_project_id			,
		x_is_lifecycle_tracking	=> l_is_lifecycle_tracking	,
		x_return_status		=> l_return_status		,
		x_errorcode		=> l_errorcode			,
		x_msg_count		=> l_msg_count			,
		x_msg_data		=> l_msg_data );

-- Note that raising and population of error messages is not done here. It is the calling api's
-- responsibility to put the error messahe into stack if required.

x_errorcode	     := l_errorcode;
x_return_status         := l_return_status;
x_is_lifecycle_tracking	:= l_is_lifecycle_tracking;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_is_lifecycle_tracking := FND_API.G_TRUE;     -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_lc_tracking_project',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_is_lifecycle_tracking := FND_API.G_TRUE;     -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_lc_tracking_project',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_is_lifecycle_tracking := FND_API.G_TRUE;     -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_lc_tracking_project',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END check_lc_tracking_project;


	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_project_ok(
	p_api_version		IN	NUMBER	   :=1.0	,
	p_project_id 		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2   := NULL	,
	x_delete_ok		OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_return_status		OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_errorcode		OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_count		OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_data		OUT	NOCOPY VARCHAR2  -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'check_delete_project_ok';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

	l_phase_id		      NUMBER;
        l_delete_ok                   VARCHAR2(1);
BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_delete_ok     := FND_API.G_FALSE;

	EGO_LIFECYCLE_USER_PUB.check_delete_project_ok(
		p_api_version		=> p_api_version	,
		p_project_id		=> p_project_id		,
		p_init_msg_list		=> p_init_msg_list	,
		x_delete_ok		=> l_delete_ok		,
		x_return_status		=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data );

	/* Bug 2760719 -- Added check for l_delete_ok  <> FND_API.G_TRUE and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_delete_ok  <> FND_API.G_TRUE OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;
x_errorcode	     := l_errorcode;
x_return_status      := l_return_status;
x_delete_ok          := l_delete_ok;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_project_ok',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_project_ok',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_project_ok',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END check_delete_project_ok;




	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/




PROCEDURE delete_all_item_assocs(
	p_api_version			IN	NUMBER		:=1.0		,
	p_project_id 			IN	NUMBER				,
	p_init_msg_list			IN	VARCHAR2 := NULL		,
	p_commit       			IN	VARCHAR2 := NULL		,
	x_errorcode   			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'delete_all_item_assocs';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;


	BEGIN

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT wrapper_delete_all_item_assocs;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

	EGO_LIFECYCLE_USER_PUB.delete_all_item_assocs(
		p_api_version		=> p_api_version	,
		p_project_id		=> p_project_id		,
		p_commit		=> p_commit		,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_return_status 	=> l_return_status	,
		x_msg_data		=> l_msg_data );

/* Bug 2760719 -- Added check for l_return_status  <> FND_API.G_RET_STS_SUCCESS and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	END IF;

x_errorcode	     := l_errorcode;
x_return_status      := l_return_status;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
        COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_delete_all_item_assocs;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'delete_all_item_assocs',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'delete_all_item_assocs',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_delete_all_item_assocs;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_delete_all_item_assocs;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'delete_all_item_assocs',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END delete_all_item_assocs;

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/


FUNCTION CHECK_PLM_INSTALLED RETURN char
 is
  cursor get_application_id is
  select application_id
  from fnd_application
  where application_short_name = 'EGO';
  x_application_id fnd_application.application_id%TYPE;

  Cursor get_installation_status is
  select nvl(status,'N') from fnd_product_installations
  where application_id = x_application_id;

  x_status fnd_product_installations.status%TYPE;

Begin
   -- Get the Application_id from the application short name
   open get_application_id;
   fetch get_application_id into x_application_id;
   if(get_application_id%NOTFOUND) then
     close get_application_id;
     return 'N';
   end if;
   close get_application_id;
 -- Get the application_status I - Installed, S - Installed in shared mode, N - Not Installed
   open get_installation_status;
   fetch get_installation_status into x_status;
   if(get_installation_status%NOTFOUND) then
     close get_installation_status;
     return 'N';
   end if;
   close get_installation_status;

   if(x_status <> 'N') then
     return 'Y';
  else
     return 'N';
  end if;

end CHECK_PLM_INSTALLED;



	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE copy_item_assocs(
	p_api_version			IN	NUMBER		:=1.0		,
	p_project_id_from 		IN	NUMBER				,
        p_project_id_to                 IN      NUMBER                          ,
	p_init_msg_list			IN	VARCHAR2 := NULL		,
	p_commit       			IN	VARCHAR2 := NULL		,
	x_return_status			OUT	NOCOPY VARCHAR2			, -- NOCOPY change for Bug 4939368
	x_errorcode   			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_count			OUT	NOCOPY NUMBER				, -- NOCOPY change for Bug 4939368
	x_msg_data			OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'copy_item_assocs';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;


	BEGIN

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT wrapper_copy_item_assocs;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;

	EGO_LIFECYCLE_USER_PUB.copy_item_assocs(
		p_api_version		=> p_api_version	,
		p_project_id_to		=> p_project_id_to	,
                p_project_id_from	=> p_project_id_from    ,
		p_commit		=> p_commit		,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_return_status 	=> l_return_status	,
		x_msg_data		=> l_msg_data );

	/* Bug 2760719 -- Added check for l_return_status  <> FND_API.G_RET_STS_SUCCESS and moved raise statement
                  outside the IF l_msg_count > 0 */

	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
	          If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	END IF;
x_errorcode	     := l_errorcode;
x_return_status      := l_return_status;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
        COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_copy_item_assocs;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'copy_item_assocs',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'copy_item_assocs',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_copy_item_assocs;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrapper_copy_item_assocs;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'copy_item_assocs',
                            p_error_text     =>  x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END copy_item_assocs;

/* Start for Changes made for Integration with Eng */
	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_project_ok_eng(
	p_api_version		IN	NUMBER	   :=1.0	,
	p_project_id 		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2   := NULL	,
	x_delete_ok		OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_return_status		OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_errorcode		OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_count		OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_data		OUT	NOCOPY VARCHAR2  -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'check_delete_project_ok_eng';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;

        l_delete_ok                   VARCHAR2(1);
BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_delete_ok     := FND_API.G_FALSE;

	ENG_LIFECYCLE_USER_PUB.check_delete_project_ok(
		p_api_version		=> p_api_version	,
		p_project_id		=> p_project_id		,
		p_init_msg_list		=> p_init_msg_list	,
		x_delete_ok		=> l_delete_ok		,
		x_return_status		=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data );

	IF l_delete_ok  <> FND_API.G_TRUE OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;
x_errorcode	     := l_errorcode;
x_return_status      := l_return_status;
x_delete_ok          := l_delete_ok;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_project_ok_eng',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_project_ok_eng',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_project_ok_eng',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END check_delete_project_ok_eng;





	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE check_delete_task_ok_eng(
	p_api_version		IN	NUMBER	   :=1.0	,
	p_task_id 		IN	NUMBER			,
	p_init_msg_list		IN	VARCHAR2   := NULL	,
	x_delete_ok		OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_return_status		OUT	NOCOPY VARCHAR2		, -- NOCOPY change for Bug 4939368
	x_errorcode		OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_count		OUT	NOCOPY NUMBER			, -- NOCOPY change for Bug 4939368
	x_msg_data		OUT	NOCOPY VARCHAR2  -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'check_delete_task_ok_eng';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;
        l_delete_ok                   VARCHAR2(1);
BEGIN

        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	x_delete_ok     := FND_API.G_FALSE;

	ENG_LIFECYCLE_USER_PUB.check_delete_task_ok(
		p_api_version		=> p_api_version	,
		p_task_id		=> p_task_id		,
		p_init_msg_list		=> p_init_msg_list	,
		x_delete_ok		=> l_delete_ok		,
		x_return_status		=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data );

	IF l_delete_ok  <> FND_API.G_TRUE OR l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
	          x_msg_count := l_msg_count;
		  If l_msg_count = 1 THEN
	             pa_interface_utils_pub.get_messages
		         (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		 End if;
		End if;
		RAISE  FND_API.G_EXC_ERROR;
	END IF;
x_errorcode	     := l_errorcode;
x_return_status      := l_return_status;
x_delete_ok          := l_delete_ok;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_task_ok_eng',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_task_ok_eng',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368

WHEN OTHERS THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_delete_ok     := FND_API.G_FALSE;            -- NOCOPY change for Bug 4939368
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'check_delete_task_ok_eng',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END check_delete_task_ok_eng;

/* End for Changes made for Integration with Eng */

/* Start Changes for Bug 2778408 */

	/*-----------------------------------------------------------+
	 | For Details/Comments Refer Package Specification Comments |
	 +-----------------------------------------------------------*/

PROCEDURE process_phase_code_delete(
	p_api_version	IN	NUMBER	:= 1.0		        ,
	p_phase_code 	IN	NUMBER			        ,
	p_init_msg_list	IN	VARCHAR2 := FND_API.G_FALSE	,
	p_commit       	IN	VARCHAR2 := FND_API.G_FALSE	,
	x_return_status	OUT	NOCOPY VARCHAR2		        , -- NOCOPY change for Bug 4939368
	x_errorcode   	OUT	NOCOPY NUMBER			        , -- NOCOPY change for Bug 4939368
	x_msg_count	OUT	NOCOPY NUMBER			        , -- NOCOPY change for Bug 4939368
	x_msg_data	OUT	NOCOPY VARCHAR2 -- NOCOPY change for Bug 4939368
	)
IS
	l_api_name	     CONSTANT VARCHAR(30) := 'process_phase_code_delete';
	l_api_version        CONSTANT NUMBER      := 1.0;
	l_msg_count                   NUMBER;
	l_msg_index_out               NUMBER;
	l_data			      VARCHAR2(2000);
	l_msg_data		      VARCHAR2(2000);
	l_return_status		      VARCHAR2(1);
	l_errorcode		      NUMBER;


	BEGIN

	IF(p_commit = FND_API.G_TRUE) THEN
	  SAVEPOINT wrp_process_phase_code_delete;
	END IF;


        IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version	,
                                           p_api_version	,
                                           l_api_name		,
                                           l_pkg_name)
        THEN
	      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;


	x_return_status := FND_API.G_RET_STS_SUCCESS;
	EGO_LIFECYCLE_ADMIN_PUB.process_phase_code_delete(
		p_api_version		=> p_api_version	,
		p_phase_code		=> p_phase_code		,
		p_init_msg_list		=> p_init_msg_list	,
		p_commit		=> p_commit		,
		x_return_status 	=> l_return_status	,
		x_errorcode		=> l_errorcode		,
		x_msg_count		=> l_msg_count		,
		x_msg_data		=> l_msg_data
		);
	IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
		l_msg_count := FND_MSG_PUB.count_msg;
		If l_msg_count > 0 THEN
		    x_msg_count := l_msg_count;
	          If l_msg_count = 1 THEN
		     pa_interface_utils_pub.get_messages
			 (p_encoded        => FND_API.G_TRUE		,
		          p_msg_index      => 1				,
		          p_msg_count      => l_msg_count		,
		          p_msg_data       => l_msg_data		,
		          p_data           => l_data			,
		          p_msg_index_out  => l_msg_index_out
			  );
		    x_msg_data := l_data;
		  End if;
		End if;
	        RAISE  FND_API.G_EXC_ERROR;
	END IF;

x_errorcode          := l_errorcode;
x_return_status      := l_return_status;

IF FND_API.TO_BOOLEAN(P_COMMIT) THEN
        COMMIT;
END IF;

EXCEPTION

WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrp_process_phase_code_delete;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'process_phase_code_delete',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368

WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'process_phase_code_delete',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrp_process_phase_code_delete;
    END IF;

WHEN OTHERS THEN
    IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO wrp_process_phase_code_delete;
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    x_errorcode     := SQLCODE;                    -- NOCOPY change for Bug 4939368
    x_msg_count     := 1;                          -- NOCOPY change for Bug 4939368
    x_msg_data      := substrb(SQLERRM,1,240);     -- NOCOPY change for Bug 4939368
    fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_EGO_WRAPPER_PUB',
                            p_procedure_name => 'process_phase_code_delete',
                            p_error_text     => x_msg_data); -- NOCOPY change for Bug 4939368
    raise;
END process_phase_code_delete;

/* End of Changes for Bug 2778408 */




END PA_EGO_WRAPPER_PUB;

/
