--------------------------------------------------------
--  DDL for Package Body VEA_TPA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_TPA_UTIL_PVT" as
/* $Header: VEATUTLB.pls 115.18 2004/07/27 00:08:33 rvishnuv ship $      */
--{
    /*========================  vea_tpa_util_pvt  ===========================*/
    /*========================================================================
       PURPOSE:  TPA Utilities Package

       NOTES:                To run the script:

                             sql> start VEATUTLB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME         CONSTANT VARCHAR2(30) := 'VEA_TPA_UTIL_PVT';
    --
    --
    G_LAYER_MERGE          BOOLEAN := FALSE;
    --
    --
    /*========================================================================

       PROCEDURE NAME: set_message

       PURPOSE: Sets an error message on the message stack

    ========================================================================*/
    PROCEDURE set_message
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 DEFAULT NULL,
	p_value1      IN      VARCHAR2 DEFAULT NULL,
	p_token2      IN      VARCHAR2 DEFAULT NULL,
	p_value2      IN      VARCHAR2 DEFAULT NULL,
	p_token3      IN      VARCHAR2 DEFAULT NULL,
	p_value3      IN      VARCHAR2 DEFAULT NULL,
	p_token4      IN      VARCHAR2 DEFAULT NULL,
	p_value4      IN      VARCHAR2 DEFAULT NULL,
	p_token5      IN      VARCHAR2 DEFAULT NULL,
	p_value5      IN      VARCHAR2 DEFAULT NULL,
	p_token6      IN      VARCHAR2 DEFAULT NULL,
	p_value6      IN      VARCHAR2 DEFAULT NULL,
	p_token7      IN      VARCHAR2 DEFAULT NULL,
	p_value7      IN      VARCHAR2 DEFAULT NULL,
	p_token8      IN      VARCHAR2 DEFAULT NULL,
	p_value8      IN      VARCHAR2 DEFAULT NULL
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'set_message';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        IF p_error_name IS NOT NULL
	THEN
	--{
	    l_location := '0020';
	    --
	    FND_MESSAGE.SET_NAME('VEA',p_error_name);
	    --
	    --
	    l_location := '0030';
	    --
	    IF  p_token1 IS NOT NULL
	    AND p_value1 IS NOT NULL
	    THEN
	    --{
	        l_location := '0040';
	        --
		FND_MESSAGE.SET_TOKEN(p_token1, p_value1);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0050';
	    --
	    IF  p_token2 IS NOT NULL
	    AND p_value2 IS NOT NULL
	    THEN
	    --{
	        l_location := '0060';
	        --
		FND_MESSAGE.SET_TOKEN(p_token2, p_value2);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0070';
	    --
	    IF  p_token3 IS NOT NULL
	    AND p_value3 IS NOT NULL
	    THEN
	    --{
	        l_location := '0080';
	        --
		FND_MESSAGE.SET_TOKEN(p_token3, p_value3);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0090';
	    --
	    IF  p_token4 IS NOT NULL
	    AND p_value4 IS NOT NULL
	    THEN
	    --{
	        l_location := '0100';
	        --
		FND_MESSAGE.SET_TOKEN(p_token4, p_value4);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0110';
	    --
	    IF  p_token5 IS NOT NULL
	    AND p_value5 IS NOT NULL
	    THEN
	    --{
	        l_location := '0120';
	        --
		FND_MESSAGE.SET_TOKEN(p_token5, p_value5);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0130';
	    --
	    IF  p_token6 IS NOT NULL
	    AND p_value6 IS NOT NULL
	    THEN
	    --{
	        l_location := '0140';
	        --
		FND_MESSAGE.SET_TOKEN(p_token6, p_value6);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0150';
	    --
	    IF  p_token7 IS NOT NULL
	    AND p_value7 IS NOT NULL
	    THEN
	    --{
	        l_location := '0160';
	        --
		FND_MESSAGE.SET_TOKEN(p_token7, p_value7);
	    --}
	    END IF;
	    --
	    --
	    l_location := '0170';
	    --
	    IF  p_token8 IS NOT NULL
	    AND p_value8 IS NOT NULL
	    THEN
	    --{
	        l_location := '0180';
	        --
		FND_MESSAGE.SET_TOKEN(p_token8, p_value8);
	    --}
	    END IF;
	    --
	    --
	    /*
	    APP_EXCEPTION.RAISE_EXCEPTION
	      (
		exception_code => 'POPS',
		exception_text => FND_MESSAGE.GET
	      );
	   */
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	   RAISE;
    --}
    END set_message;
    --
    --
    /*========================================================================

       PROCEDURE NAME: display_message

       PURPOSE: Displays the token-substituted error message in the concurrent
		program log file.

    ========================================================================*/
    PROCEDURE display_message
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 ,
	p_value1      IN      VARCHAR2 ,
	p_token2      IN      VARCHAR2 ,
	p_value2      IN      VARCHAR2 ,
	p_token3      IN      VARCHAR2 ,
	p_value3      IN      VARCHAR2 ,
	p_token4      IN      VARCHAR2 ,
	p_value4      IN      VARCHAR2 ,
	p_token5      IN      VARCHAR2 ,
	p_value5      IN      VARCHAR2 ,
	p_token6      IN      VARCHAR2 ,
	p_value6      IN      VARCHAR2 ,
	p_token7      IN      VARCHAR2 ,
	p_value7      IN      VARCHAR2 ,
	p_token8      IN      VARCHAR2 ,
	p_value8      IN      VARCHAR2
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'display_message';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_error_name IS NOT NULL
	THEN
	--{
	    l_location := '0020';
	    --
	    vea_tpa_util_pvt.set_message
	      (
	        p_error_name => p_error_name,
	        p_token1     => p_token1,
	        p_value1     => p_value1,
	        p_token2     => p_token2,
	        p_value2     => p_value2,
	        p_token3     => p_token3,
	        p_value3     => p_value3,
	        p_token4     => p_token4,
	        p_value4     => p_value4,
	        p_token5     => p_token5,
	        p_value5     => p_value5,
	        p_token6     => p_token6,
	        p_value6     => p_value6,
	        p_token7     => p_token7,
	        p_value7     => p_value7,
	        p_token8     => p_token8,
	        p_value8     => p_value8
	      );
	    --
	    --
	    l_location := '0030';
	    --
	    FND_FILE.PUT_LINE
	      (
		FND_FILE.LOG,
		FND_MESSAGE.GET
	      );
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	   RAISE;
    --}
    END display_message;
    --
    --
    /*========================================================================

       PROCEDURE NAME: add_message

       PURPOSE: Adds a message to API message stack.

    ========================================================================*/
    PROCEDURE add_message
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 ,
	p_value1      IN      VARCHAR2 ,
	p_token2      IN      VARCHAR2 ,
	p_value2      IN      VARCHAR2 ,
	p_token3      IN      VARCHAR2 ,
	p_value3      IN      VARCHAR2 ,
	p_token4      IN      VARCHAR2 ,
	p_value4      IN      VARCHAR2 ,
	p_token5      IN      VARCHAR2 ,
	p_value5      IN      VARCHAR2 ,
	p_token6      IN      VARCHAR2 ,
	p_value6      IN      VARCHAR2 ,
	p_token7      IN      VARCHAR2 ,
	p_value7      IN      VARCHAR2 ,
	p_token8      IN      VARCHAR2 ,
	p_value8      IN      VARCHAR2
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'add_message';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_error_name IS NOT NULL
	THEN
	--{
	    l_location := '0020';
	    --
	    vea_tpa_util_pvt.set_message
	      (
	        p_error_name => p_error_name,
	        p_token1     => p_token1,
	        p_value1     => p_value1,
	        p_token2     => p_token2,
	        p_value2     => p_value2,
	        p_token3     => p_token3,
	        p_value3     => p_value3,
	        p_token4     => p_token4,
	        p_value4     => p_value4,
	        p_token5     => p_token5,
	        p_value5     => p_value5,
	        p_token6     => p_token6,
	        p_value6     => p_value6,
	        p_token7     => p_token7,
	        p_value7     => p_value7,
	        p_token8     => p_token8,
	        p_value8     => p_value8
	      );
	    --
	    --
	    l_location := '0030';
	    --
	    FND_MSG_PUB.Add;
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	   RAISE;
    --}
    END add_message;
    --
    --
    /*========================================================================

       PROCEDURE NAME: add_message_and_raise

       PURPOSE: Adds a message to API message stack.

    ========================================================================*/
    PROCEDURE add_message_and_raise
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 ,
	p_value1      IN      VARCHAR2 ,
	p_token2      IN      VARCHAR2 ,
	p_value2      IN      VARCHAR2 ,
	p_token3      IN      VARCHAR2 ,
	p_value3      IN      VARCHAR2 ,
	p_token4      IN      VARCHAR2 ,
	p_value4      IN      VARCHAR2 ,
	p_token5      IN      VARCHAR2 ,
	p_value5      IN      VARCHAR2 ,
	p_token6      IN      VARCHAR2 ,
	p_value6      IN      VARCHAR2 ,
	p_token7      IN      VARCHAR2 ,
	p_value7      IN      VARCHAR2 ,
	p_token8      IN      VARCHAR2 ,
	p_value8      IN      VARCHAR2
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'add_message_and_raise';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_error_name IS NOT NULL
	THEN
	--{
	    l_location := '0020';
	    --
	    vea_tpa_util_pvt.add_message
	      (
	        p_error_name => p_error_name,
	        p_token1     => p_token1,
	        p_value1     => p_value1,
	        p_token2     => p_token2,
	        p_value2     => p_value2,
	        p_token3     => p_token3,
	        p_value3     => p_value3,
	        p_token4     => p_token4,
	        p_value4     => p_value4,
	        p_token5     => p_token5,
	        p_value5     => p_value5,
	        p_token6     => p_token6,
	        p_value6     => p_value6,
	        p_token7     => p_token7,
	        p_value7     => p_value7,
	        p_token8     => p_token8,
	        p_value8     => p_value8
	      );
	    --
	    --
	    l_location := '0030';
	    --
	    RAISE FND_API.G_EXC_ERROR;
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	   RAISE;
    --}
    END add_message_and_raise;
    --
    --
    /*========================================================================

       PROCEDURE NAME: add_exc_message

       PURPOSE: Adds a message for unexpected errors, to API message stack.

    ========================================================================*/
    PROCEDURE add_exc_message
      (
	p_package_name           IN     VARCHAR2,
	p_api_name               IN     VARCHAR2,
	p_location               IN     VARCHAR2
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'add_exc_message';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	vea_tpa_util_pvt.add_message
	  (
	    p_error_name => 'VEA_PLSQL_UNEXPECTED_ERROR',
	    p_token1     => 'PACKAGE_NAME',
	    p_value1     => p_package_name,
	    p_token2     => 'API_NAME',
	    p_value2     => p_api_name,
	    p_token3     => 'LOCATION',
	    p_value3     => p_location,
	    p_token4     => 'ORACLE_ERROR_TEXT',
	    p_value4     => sqlerrm
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	   RAISE;
    --}
    END add_exc_message;
    --
    --
    /*========================================================================

       PROCEDURE NAME: add_exc_message

       PURPOSE: Adds a message for unexpected errors, to API message stack
		and raises an exception.

    ========================================================================*/
    PROCEDURE add_exc_message_and_raise
      (
	p_package_name           IN     VARCHAR2,
	p_api_name               IN     VARCHAR2,
	p_location               IN     VARCHAR2
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'add_exc_message_and_raise';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	--
	vea_tpa_util_pvt.add_exc_message
	  (
	    p_package_name     => p_package_name,
	    p_api_name     => p_api_name,
	    p_location     => p_location
	  );
	--
	--
	l_location := '0020';
	--
	RAISE vea_tpa_util_pvt.e_unexpected_error;
    --}
    EXCEPTION
    --{
	WHEN OTHERS THEN
	   RAISE;
    --}
    END add_exc_message_and_raise;
    --
    --
    /*========================================================================

       PROCEDURE NAME: handle_error

       PURPOSE: Standard error handler as per Business object API standards

    ========================================================================*/
    PROCEDURE
      handle_error
	(
          p_error_type    	   IN  	  VARCHAR2,
          p_savepoint_name    	   IN  	  VARCHAR2,
	  p_package_name           IN     VARCHAR2,
	  p_api_name               IN     VARCHAR2,
	  p_location               IN     VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
	  x_api_return_status      OUT NOCOPY     VARCHAR2
	)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'handle_error';
        l_location            VARCHAR2(32767);
        l_statement           VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_statement := 'ROLLBACK TO ' || p_savepoint_name;
	--
	--
	l_location := '0011';
	--
	EXECUTE IMMEDIATE l_statement;
	--
	--
	l_location := '0020';
	--
	IF p_error_type = G_ERROR
	THEN
	--{
	     l_location := '0030';
	     --
	     x_api_return_status := FND_API.G_RET_STS_ERROR;
	--}
	ELSIF p_error_type = G_UNEXPECTED_ERROR
	THEN
	--{
	    l_location := '0040';
	    --
	     x_api_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	--}
	ELSE
	--{
	    l_location := '0050';
	    --
	     x_api_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	     --
	     --
	    l_location := '0060';
	    --
	     --IF FND_MSG_PUB.Check_Msg_Level( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )
	     --THEN
	     --{
	         l_location := '0070';
	         --
		 vea_tpa_util_pvt.add_exc_message
		   (
		     p_package_name => p_package_name,
		     p_api_name     => p_api_name,
		     p_location     => p_location
		   );
		 /*
	         FND_MSG_PUB.Add_Exc_Msg
	           (
	             p_package_name,
	             p_api_name
	           );
                 */
	     --}
	     --END IF;
	--}
	END IF;
	--
	--
	l_location := '0080';
	--
	FND_MSG_PUB.Count_and_Get
	  (
	    p_count   => x_msg_count,
	    p_data    => x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
	--
	--
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END handle_error;
    --
    --
    /*========================================================================

       PROCEDURE NAME: api_post_call

       PURPOSE: Implements standard API post call process, as per business
		object API standards

    ========================================================================*/
    PROCEDURE
      api_post_call
	(
          p_msg_count	           IN	  NUMBER,
          p_msg_data		   IN	  VARCHAR2,
	  p_api_return_status      IN    VARCHAR2
	)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'api_post_call';
        l_location            VARCHAR2(32767);
	--
	--
	l_count               NUMBER;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_msg_count = 1
	THEN
	--{
	    l_location := '0020';
	    --
	    FND_FILE.PUT_LINE
	      (
		FND_FILE.LOG,
		p_msg_data
	      );
	--}
	ELSE
	--{
	    l_location := '0030';
	    --
	    FOR l_count IN 1..NVL(p_msg_count,0)
	    LOOP
	    --{
	        l_location := '0040';
	        --
	        FND_FILE.PUT_LINE
	          (
		    FND_FILE.LOG,
		    FND_MSG_PUB.GET( p_encoded => FND_API.G_FALSE )
	          );
	--}
	END LOOP;
	--}
	END IF;
	--
	--
	l_location := '0050';
	--
	IF nvl(p_api_return_status, FND_API.G_RET_STS_SUCCESS ) = FND_API.G_RET_STS_SUCCESS
	THEN
	--{
	    l_location := '0060';
	    --
	    NULL;
	--}
	ELSE
	--{
	    l_location := '0070';
	    --
	    ROLLBACK WORK;
	    --
	    --
	    l_location := '0080';
	    --
	    --APP_EXCEPTION.RAISE_EXCEPTION;
	    RAISE FND_API.G_EXC_ERROR;
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END api_post_call;
    --
    --
    /*========================================================================

       PROCEDURE NAME: api_header

       PURPOSE: Standard API header as per Business object API standards

    ========================================================================*/
    PROCEDURE
      api_header
	(
	  p_package_name            IN     VARCHAR2,
	  p_api_name                IN     VARCHAR2,
	  p_api_type                IN     VARCHAR2,
	  p_api_current_version     IN     NUMBER,
	  p_api_caller_version      IN     NUMBER,
          p_init_msg_list	    IN	   VARCHAR2 := FND_API.G_FALSE,
	  x_savepoint_name          OUT NOCOPY     VARCHAR2,
	  x_api_return_status       OUT NOCOPY     VARCHAR2
	)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'api_header';
        l_location            VARCHAR2(32767);
	l_savepoint_name      VARCHAR2(30);
	l_statement           VARCHAR2(32767);
    --}
    BEGIN
    --{
	-- Standard Start of API Savepoint
	--
	l_location := '0010';
	--
	l_savepoint_name := SUBSTR(p_package_name,1,18)
			    || '_'
			    || SUBSTR(p_api_name,1,7)
			    || '_'
			    || p_api_type;
	--
	--
	l_location := '0020';
	--
	x_savepoint_name := l_savepoint_name;
	--
	--
	l_location := '0030';
	--
	l_statement := 'SAVEPOINT ' || l_savepoint_name;
	--
	--
	l_location := '0031';
	--
	EXECUTE IMMEDIATE l_statement;
	--
	--
	-- Standard call to check for call compatibility
	--
	l_location := '0040';
	--
	IF NOT FND_API.Compatible_API_Call
		 (
		   p_api_current_version,
		   p_api_caller_version,
		   p_api_name,
		   p_package_name
		 )
	THEN
	--{
	     l_location := '0050';
	     --
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	--}
	END IF;
	--
	--
	-- Initialize message list if p_init_msg_list is set to TRUE
	--
	l_location := '0060';
	--
	IF FND_API.to_Boolean( p_init_msg_list )
	THEN
	--{
	     l_location := '0070';
	     --
	    FND_MSG_PUB.initialize;
	--}
	END IF;
	--
	--
	-- Initialize API return status to Success
	--
	l_location := '0080';
	--
	x_api_return_status := FND_API.G_RET_STS_SUCCESS;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END api_header;
    --
    --
    /*========================================================================

       PROCEDURE NAME: api_footer

       PURPOSE: Standard API footer as per Business object API standards

    ========================================================================*/
    PROCEDURE
      api_footer
	(
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2
	)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'api_footer';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	--
	--
	-- Standard check of p_commit
	--
	l_location := '0010';
	--
	IF FND_API.to_Boolean( p_commit )
	THEN
	--{
	     l_location := '0020';
	     --
	    commit work;
	--}
	END IF;
	--
	--
	-- Standard call to get message count
	-- and if count is 1, get message info
	--
	l_location := '0030';
	--
	FND_MSG_PUB.Count_and_Get
	  (
	    p_count   => x_msg_count,
	    p_data    => x_msg_data,
	    p_encoded => FND_API.G_FALSE
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END api_footer;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_profile_value

       PURPOSE: Obtains profile value - Cover API for FND API

    ========================================================================*/
    FUNCTION
      get_profile_value
        (
          p_profile_name           IN     VARCHAR2
        )
      RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_profile_value';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';

	--
	RETURN( FND_PROFILE.VALUE(p_profile_name) );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END get_profile_value;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_curr_layer_provider_code

       PURPOSE: Convenience method to obtain current layer provider code
		profile value

    ========================================================================*/
    FUNCTION
      get_curr_layer_provider_code
      RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_curr_layer_provider_code';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	RETURN( get_profile_value('VEA_LAYER_PROVIDER') );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END get_curr_layer_provider_code;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_curr_customer_name

       PURPOSE: Convenience method to obtain current customer name
		profile value

    ========================================================================*/
    FUNCTION
      get_curr_customer_name
      RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_curr_customer_name';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	RETURN( get_profile_value('VEA_CUSTOMER') );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END get_curr_customer_name;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_user_id

       PURPOSE: Returns current user ID - Cover API for FND API

    ========================================================================*/
    FUNCTION
      get_user_id
      RETURN NUMBER
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_user_id';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	RETURN( FND_GLOBAL.USER_ID );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END get_user_id;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_login_id

       PURPOSE: Returns current login ID - Cover API for FND API

    ========================================================================*/
    FUNCTION
      get_login_id
      RETURN NUMBER
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_login_id';
        l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	RETURN( FND_GLOBAL.LOGIN_ID );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END get_login_id;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_constants

       PURPOSE: Obtains values of various constants required by java clients
		- Cover API to access package level global constants

    ========================================================================*/
    PROCEDURE
      get_constants
	(
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          x_true	           OUT NOCOPY 	  VARCHAR2,
          x_false                  OUT NOCOPY 	  VARCHAR2,
          x_valid_level_full       OUT NOCOPY 	  NUMBER,
          x_valid_level_none       OUT NOCOPY 	  NUMBER,
          x_success                OUT NOCOPY 	  VARCHAR2,
          x_error                  OUT NOCOPY 	  VARCHAR2,
          x_unexpected_error       OUT NOCOPY 	  VARCHAR2,
	  x_next                   OUT NOCOPY     NUMBER
	)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_constants';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
	--
	--
        l_location            VARCHAR2(32767);
	l_savepoint_name      VARCHAR2(30);
    --}
    BEGIN
    --{
	--
	-- Standard API Header
	--
	l_location := '0010';
	--
	vea_tpa_util_pvt.api_header
	  (
	    p_package_name                => G_PACKAGE_NAME,
	    p_api_name                    => l_api_name,
	    p_api_type                    => l_api_type,
	    p_api_current_version         => l_api_version,
	    p_api_caller_version          => p_api_version,
	    p_init_msg_list               => p_init_msg_list,
	    x_savepoint_name              => l_savepoint_name,
	    x_api_return_status           => x_return_status
	  );
	--
	--
	--{ API Body
	--
	--
	l_location := '0010';
	--
	x_true                := FND_API.G_TRUE;
	x_false               := FND_API.G_FALSE;
	--
	l_location := '0020';
	--
	x_valid_level_full    := FND_API.G_VALID_LEVEL_FULL;
	x_valid_level_none    := FND_API.G_VALID_LEVEL_NONE;
	--
	l_location := '0030';
	--
	x_success             := FND_API.G_RET_STS_SUCCESS;
	x_error               := FND_API.G_RET_STS_ERROR;
	x_unexpected_error    := FND_API.G_RET_STS_UNEXP_ERROR;
	--
	--
	l_location := '0040';
	--
	x_next                := FND_MSG_PUB.G_NEXT;
	--
	--
	--} API Body
	--
	--
	-- Standard  API Footer
	--
	l_location := '0040';
	--
	vea_tpa_util_pvt.api_footer
	  (
	    p_commit                      => p_commit,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data
	  );
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    --RAISE;
	    vea_tpa_util_pvt.handle_error
	      (
	        p_error_type                  => vea_tpa_util_pvt.G_ERROR,
	        p_savepoint_name              => l_savepoint_name,
	        p_package_name                => G_PACKAGE_NAME,
	        p_api_name                    => l_api_name,
	        p_location                    => l_location,
	        x_msg_count                   => x_msg_count,
	        x_msg_data                    => x_msg_data,
	        x_api_return_status           => x_return_status
	      );
	--}
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	--{
	    --RAISE;
	    vea_tpa_util_pvt.handle_error
	      (
	        p_error_type                  => vea_tpa_util_pvt.G_UNEXPECTED_ERROR,
	        p_savepoint_name              => l_savepoint_name,
	        p_package_name                => G_PACKAGE_NAME,
	        p_api_name                    => l_api_name,
	        p_location                    => l_location,
	        x_msg_count                   => x_msg_count,
	        x_msg_data                    => x_msg_data,
	        x_api_return_status           => x_return_status
	      );
	--}
	WHEN OTHERS
	THEN
	--{
	    --RAISE;
	    vea_tpa_util_pvt.handle_error
	      (
	        p_error_type                  => vea_tpa_util_pvt.G_OTHER_ERROR,
	        p_savepoint_name              => l_savepoint_name,
	        p_package_name                => G_PACKAGE_NAME,
	        p_api_name                    => l_api_name,
	        p_location                    => l_location,
	        x_msg_count                   => x_msg_count,
	        x_msg_data                    => x_msg_data,
	        x_api_return_status           => x_return_status
	      );
	--}
    --}
    END get_constants;
    --
    --
    /*========================================================================

       PROCEDURE NAME: isVEAInstalled

       PURPOSE: Reports installation status of VEA product.

    ========================================================================*/
    PROCEDURE
      isVEAInstalled
	(
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
	  x_vea_install_status     OUT NOCOPY     VARCHAR2
	)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'isVEAInstalled';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
	--
	--
        l_location            VARCHAR2(32767);
	l_savepoint_name      VARCHAR2(30);
	l_install    BOOLEAN;
	l_org        VARCHAR2(32767);
    --}
    BEGIN
    --{
	--
	-- Standard API Header
	--
	l_location := '0010';
	--
	vea_tpa_util_pvt.api_header
	  (
	    p_package_name                => G_PACKAGE_NAME,
	    p_api_name                    => l_api_name,
	    p_api_type                    => l_api_type,
	    p_api_current_version         => l_api_version,
	    p_api_caller_version          => p_api_version,
	    p_init_msg_list               => p_init_msg_list,
	    x_savepoint_name              => l_savepoint_name,
	    x_api_return_status           => x_return_status
	  );
	--
	--
	--{ API Body
	--
	--
	l_location := '0020';
	--
        l_install := fnd_installation.get(663,663,x_vea_install_status,l_org);
	--
	--
	--} API Body
	--
	--
	-- Standard  API Footer
	--
	l_location := '0030';
	--
	vea_tpa_util_pvt.api_footer
	  (
	    p_commit                      => p_commit,
	    x_msg_count                   => x_msg_count,
	    x_msg_data                    => x_msg_data
	  );
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    --RAISE;
	    vea_tpa_util_pvt.handle_error
	      (
	        p_error_type                  => vea_tpa_util_pvt.G_ERROR,
	        p_savepoint_name              => l_savepoint_name,
	        p_package_name                => G_PACKAGE_NAME,
	        p_api_name                    => l_api_name,
	        p_location                    => l_location,
	        x_msg_count                   => x_msg_count,
	        x_msg_data                    => x_msg_data,
	        x_api_return_status           => x_return_status
	      );
	--}
	WHEN FND_API.G_EXC_UNEXPECTED_ERROR
	THEN
	--{
	    --RAISE;
	    vea_tpa_util_pvt.handle_error
	      (
	        p_error_type                  => vea_tpa_util_pvt.G_UNEXPECTED_ERROR,
	        p_savepoint_name              => l_savepoint_name,
	        p_package_name                => G_PACKAGE_NAME,
	        p_api_name                    => l_api_name,
	        p_location                    => l_location,
	        x_msg_count                   => x_msg_count,
	        x_msg_data                    => x_msg_data,
	        x_api_return_status           => x_return_status
	      );
	--}
	WHEN OTHERS
	THEN
	--{
	    --RAISE;
	    vea_tpa_util_pvt.handle_error
	      (
	        p_error_type                  => vea_tpa_util_pvt.G_OTHER_ERROR,
	        p_savepoint_name              => l_savepoint_name,
	        p_package_name                => G_PACKAGE_NAME,
	        p_api_name                    => l_api_name,
	        p_location                    => l_location,
	        x_msg_count                   => x_msg_count,
	        x_msg_data                    => x_msg_data,
	        x_api_return_status           => x_return_status
	      );
	--}
    --}
    END isVEAInstalled;
    --
    --
    /*========================================================================

       PROCEDURE NAME: isVEAInstalled

       PURPOSE: Returns True, if VEA product is installed.

    ========================================================================*/
    FUNCTION
      is_vea_installed
    RETURN BOOLEAN
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'is_vea_installed';
        l_location            VARCHAR2(32767);
	l_install    BOOLEAN;
	l_vea_status VARCHAR2(32767);
	l_org        VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        l_install := fnd_installation.get(663,663,l_vea_status,l_org);
	--
	--
	l_location := '0020';
	--
	IF l_vea_status = 'I'
	THEN
	    RETURN(TRUE);
	ELSE
	    RETURN(FALSE);
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END is_vea_installed;
    --
    --
    /*========================================================================

       PROCEDURE NAME: preProcess

       PURPOSE: Handles processing at the beginning of layer merge. It deletes
		all information in the repository pertaining to the specified
		TP layer developed by the specified layer provider for the
		specified TP application.  It also sets a variable to indicate
		that layer merge process has begun.
    ========================================================================*/
    PROCEDURE
      preProcess
        (
          p_api_version            IN     NUMBER,
          p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                 IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level       IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status          OUT NOCOPY     VARCHAR2,
          x_msg_count              OUT NOCOPY     NUMBER,
          x_msg_data               OUT NOCOPY     VARCHAR2,
          p_layer_provider_code    IN     vea_layers.layer_provider_code%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_tp_layer_name          IN     vea_tp_layers.name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'preProcess';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
        --
        --
        l_location            VARCHAR2(32767);
        l_savepoint_name      VARCHAR2(30);
        --
        --
        l_tp_layer_id NUMBER;
        --
        --
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF NOT( vea_tpa_util_pvt.is_vea_installed() )
	THEN
	   RETURN;
	END IF;
	--
	--
        -- Standard API Header
        --
	l_location := '0020';
	--
        vea_tpa_util_pvt.api_header
          (
            p_package_name                => G_PACKAGE_NAME,
            p_api_name                    => l_api_name,
            p_api_type                    => l_api_type,
            p_api_current_version         => l_api_version,
            p_api_caller_version          => p_api_version,
            p_init_msg_list               => p_init_msg_list,
            x_savepoint_name              => l_savepoint_name,
            x_api_return_status           => x_return_status
          );
        --
        --
        --{ API Body
        --
	--
	--
	l_location := '0030';
	--
	G_LAYER_MERGE := TRUE;
	--
	--
	g_current_layer_provider_code := get_curr_layer_provider_code;
	--
        g_tpLyr_fileId_dbId_tbl.delete;
        g_tpLyr_fileId_dbId_ext_tbl.delete;
        g_PU_fileId_dbId_tbl.delete;
        g_PU_fileId_dbId_ext_tbl.delete;
        g_pend_puId_tpaPUId_tbl.delete;
        g_pend_puId_tpaPUId_ext_tbl.delete;
	--
	--
	l_location := '0040';
	--
	vea_layers_sv.populateLayerActiveTable
	  (
	    p_layer_provider_code => p_layer_provider_code
	  );
	--
	--
	l_location := '0050';
	--
        l_tp_layer_id :=
	vea_tp_layers_sv.getId
	  (
	    p_layer_provider_code    => p_layer_provider_code,
	    p_tp_layer_name          => p_tp_layer_name
	  );
	--
	--
	l_location := '0060';
	--
	vea_tp_layers_sv.delete_rows
	  (
	    p_layer_provider_code    => p_layer_provider_code,
	    p_tp_layer_id            => l_tp_layer_id,
	    p_tp_layer_name          => p_tp_layer_name,
	    p_application_short_name => p_application_short_name
	  );
        --
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0070';
	--
        vea_tpa_util_pvt.api_footer
          (
            p_commit                      => p_commit,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data
          );
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_UNEXPECTED_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
        WHEN OTHERS
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_OTHER_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
    --}
    END preProcess;
    --
    --
    /*========================================================================

       PROCEDURE NAME: postProcess

       PURPOSE: Handles processing at the end of layer merge. It deletes any
		TP layers not licensed to current customer. It also sets a
		variable to indicate that layer merge process has ended.


       MODIFIED: This procedure has been modified by Ravi (rvishnuv) on 09/29/2000.
                 An additional parameter "layer_provider_name" has been added to
                 the existing parameters list for the procedure.

     ========================================================================*/
    PROCEDURE
      postProcess
        (
          p_api_version            IN     NUMBER,
          p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                 IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level       IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status          OUT NOCOPY     VARCHAR2,
          x_msg_count              OUT NOCOPY     NUMBER,
          x_msg_data               OUT NOCOPY     VARCHAR2,
          p_layer_provider_code    IN     vea_layers.layer_provider_code%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_tp_layer_name          IN     vea_tp_layers.name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'postProcess';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
        --
        --
        l_location            VARCHAR2(32767);
        l_savepoint_name      VARCHAR2(30);
        l_tp_layer_id NUMBER;
	l_index NUMBER;
	l_program_unit_id NUMBER;
	l_tpa_program_unit_id NUMBER;
        --
        --
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF NOT( vea_tpa_util_pvt.is_vea_installed() )
	THEN
	   RETURN;
	END IF;
	--
	--
        -- Standard API Header
        --
	l_location := '0020';


	--
        vea_tpa_util_pvt.api_header
          (
            p_package_name                => G_PACKAGE_NAME,
            p_api_name                    => l_api_name,
            p_api_type                    => l_api_type,
            p_api_current_version         => l_api_version,
            p_api_caller_version          => p_api_version,
            p_init_msg_list               => p_init_msg_list,
            x_savepoint_name              => l_savepoint_name,
            x_api_return_status           => x_return_status
          );
        --
        --
        --{ API Body
        --
	--
	l_location := '0030';
	--
	--
        l_index := g_pend_puId_tpaPUId_tbl.FIRST;
	--
	WHILE l_index IS NOT NULL
	LOOP
	--{
	    l_location := '0040';
	    --
	    l_program_unit_id := g_pend_puId_tpaPUId_tbl(l_index).key;
	    --
	    --
	    l_location := '0050';
	    --
	    vea_tpa_util_pvt.get
	          (
	            p_key                => g_pend_puId_tpaPUId_tbl(l_index).value,
	            p_cache_tbl          => g_PU_fileId_dbId_tbl,
	            p_cache_ext_tbl      => g_PU_fileId_dbId_ext_tbl,
	            x_value              => l_tpa_program_unit_id
	          );
	    --
	    --
	    l_location := '0060';
	    --
	    VEA_PROGRAM_UNITS_SV.deleteUnreferencedProgramUnits
	      (
	        p_layer_provider_code          => p_layer_provider_code,
	        p_program_unit_id              => l_program_unit_id,
	        p_tpa_program_unit_id          => l_tpa_program_unit_id
	      );
	    --
	    --
	    l_location := '0070';
	    --
	    UPDATE vea_program_units
	    SET    tpa_program_unit_id = l_tpa_program_unit_id
	    WHERE  layer_provider_code = p_layer_provider_code
	    AND    program_unit_id     = l_program_unit_id;
	    --
	    --
	    l_index := g_pend_puId_tpaPUId_tbl.NEXT(l_index);
	--}
	END LOOP;
	--
	--
	--
	l_location := '0080';
	--
	--
        l_index := g_pend_puId_tpaPUId_ext_tbl.FIRST;
	--
	WHILE l_index IS NOT NULL
	LOOP
	--{
	    l_location := '0090';
	    --
	    l_program_unit_id := g_pend_puId_tpaPUId_ext_tbl(l_index).key;
	    --
	    --
	    l_location := '0100';
	    --
	    vea_tpa_util_pvt.get
	          (
	            p_key                => g_pend_puId_tpaPUId_ext_tbl(l_index).value,
	            p_cache_tbl          => g_PU_fileId_dbId_tbl,
	            p_cache_ext_tbl      => g_PU_fileId_dbId_ext_tbl,
	            x_value              => l_tpa_program_unit_id
	          );
	    --
	    --
	    l_location := '0110';
	    --
	    VEA_PROGRAM_UNITS_SV.deleteUnreferencedProgramUnits
	      (
	        p_layer_provider_code          => p_layer_provider_code,
	        p_program_unit_id              => l_program_unit_id,
	        p_tpa_program_unit_id          => l_tpa_program_unit_id
	      );
	    --
	    --
	    l_location := '0120';
	    --
	    UPDATE vea_program_units
	    SET    tpa_program_unit_id = l_tpa_program_unit_id
	    WHERE  layer_provider_code = p_layer_provider_code
	    AND    program_unit_id     = l_program_unit_id;
	    --
	    --
	    l_index := g_pend_puId_tpaPUId_ext_tbl.NEXT(l_index);
	--}
	END LOOP;
	--
	--
	l_location := '0130';
	--
       vea_tp_layers_sv.deleteUnlicensedLayers
	  (
	    p_layer_provider_code => p_layer_provider_code
	  );
        --
        --
	l_location := '0140';
        --
        --
        -- Check if a Layer Provider has an Layers, if not then delete the Layer Provider Code. Bug No: 1387766 - rvishnuv

        vea_layerproviders_sv.delete_rows
          (
           p_layer_provider_code => p_layer_provider_code
           );
        --
        --
        l_location :='0150';
	--
        --
        vea_packages_sv.deleteUnreferencedPackages;
        --
        l_location :='0155';
        --
        l_tp_layer_id :=
	vea_tp_layers_sv.getId
	  (
	    p_layer_provider_code    => p_layer_provider_code,
	    p_tp_layer_name          => p_tp_layer_name
	  );
	--
        --
	l_location := '0160';
	--
        -- Check if customer site only then process conflicting layers
        --IF (( get_curr_layer_provider_code = 'CUST') AND (get_curr_customer_name != 'CUST')) THEN (This will not process layers belonging to a customer named "CUST")
        IF ( get_curr_layer_provider_code = 'CUST') THEN
            --
            --
	    --vea_layers_sv.processConflictingLayers;
	    vea_layers_sv.processConflictingLayers
              (
                p_tp_layer_id             =>  l_tp_layer_id, --p_tp_layer_id,
                p_layer_provider_code       =>  p_layer_provider_code
              );
            --
            --
        END IF;
        --
        --
	l_location := '0170';
	--
	G_LAYER_MERGE := FALSE;
        --
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0180';
	--
        vea_tpa_util_pvt.api_footer
          (
            p_commit                      => p_commit,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data
          );
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_UNEXPECTED_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
        WHEN OTHERS
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_OTHER_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
    --}
    END postProcess;
    --
    --
    /*========================================================================

       PROCEDURE NAME: isLayerMergeOn

       PURPOSE: Returns true, if layer merge is going on.

    ========================================================================*/
    FUNCTION  isLayerMergeOn
    RETURN  BOOLEAN
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'isLayerMergeOn';
        l_location            VARCHAR2(32767);
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        RETURN (G_LAYER_MERGE);
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END  isLayerMergeOn;
    --
    --
    /*========================================================================

       PROCEDURE NAME: populateLayerActiveTable

       PURPOSE: This procedure queries the TPA repository for the specified
		customizable program unit and stores active/inactive status
		of each layer within the customizable program unit in a
		PL/SQL table (layer cache). This procedure is called
		at the beginning of each TPA program unit. Layer cache is
		later used to check if layer is active/inactive.

    ========================================================================*/
    PROCEDURE
      populateLayerActiveTable
	(
          p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id      IN      vea_program_units.program_unit_id%TYPE,
          x_layer_table          IN OUT NOCOPY   g_layer_tbl_type
	)
    IS
    --{
	l_layer_rec      g_layer_rec_type;
	l_queryRequired  BOOLEAN := FALSE;
	l_index          NUMBER;
	l_layerTblCount  NUMBER;
	l_startPosition  NUMBER;
	--
	--
        CURSOR  layer_cur
        IS
          SELECT LA.layer_provider_code,
                 LA.layer_id,
                 DECODE(TLA.ACTIVE_FLAG, 'N', 'N', LA.ACTIVE_FLAG) IS_LAYER_ACTIVE
          FROM   vea_layers LA,
                 vea_program_units PU,
                 vea_layer_headers LH,
                 vea_program_units APU,
                 vea_packages PK,
                 vea_tp_layers TLA
          WHERE  PU.program_unit_id      = p_program_unit_id
          AND    PU.layer_provider_code  = p_layer_provider_code
          AND    LH.program_unit_id      = PU.program_unit_id
          AND    LH.program_unit_lp_code = PU.layer_provider_code
          AND    LA.layer_provider_code  = LH.layer_provider_code
          AND    LA.layer_header_id      = LH.layer_header_id
          AND    APU.layer_provider_code = LA.program_unit_lp_code
	  AND    APU.program_unit_id     = LA.new_program_unit_id
	  AND    PK.layer_provider_code  = APU.layer_provider_code
	  AND    PK.package_id           = APU.package_id
	  AND    TLA.layer_provider_code = PK.layer_provider_code
	  AND    TLA.tp_layer_id         = PK.tp_layer_id;
    --}
    BEGIN
    --{
	l_queryRequired := TRUE;
	--
	--
	IF p_program_unit_id < C_INDEX_LIMIT
	THEN
	--{
	    IF g_programUnit_Tbl.EXISTS(p_program_unit_id)
	    THEN
		l_queryRequired := FALSE;
	    END IF;
	--}
	ELSE
	--{
	    l_index := g_programUnitExt_Tbl.FIRST;
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
	    --{
	        IF g_programUnitExt_Tbl(l_index).program_unit_id = p_program_unit_id
		THEN
		    l_queryRequired := FALSE;
		    EXIT;
		END IF;
		--
		--
		l_index := g_programUnitExt_Tbl.NEXT(l_index);
	    --}
	    END LOOP;
	--}
	END IF;
	--
	--
	IF l_queryRequired
	THEN
	--{
	    --dbms_output.put_line('Query Required');
	    l_layerTblCount := g_layer_Tbl.COUNT;
	    l_startPosition := l_layerTblCount;
	    --
            FOR layer_rec IN layer_cur
            LOOP
            --{
	        l_layer_rec.layer_id := layer_rec.layer_id;
	        l_layer_rec.layer_provider_code := layer_rec.layer_provider_code;
                --
                --
                IF layer_rec.is_layer_active = 'Y'
                THEN
                --{
                    l_layer_rec.is_layer_active := TRUE;
                --}
                ELSE
                --{
                    l_layer_rec.is_layer_active := FALSE;
                --}
                END IF ;
	        --
	        --
		IF l_layerTblCount = l_startPosition
		THEN
		--{
		    --dbms_output.put_line('PU Table PUT');
	            IF p_program_unit_id < C_INDEX_LIMIT
		    THEN
		    --{
			g_programUnit_Tbl(p_program_unit_id).program_unit_id := p_program_unit_id;
			g_programUnit_Tbl(p_program_unit_id).start_position  := l_startPosition;
		    --}
		    ELSE
		    --{
			g_programUnitExt_Tbl(g_programUnitExt_Tbl.COUNT).program_unit_id  := p_program_unit_id;
			g_programUnitExt_Tbl(g_programUnitExt_Tbl.COUNT-1).start_position := l_startPosition;
		    --}
		    END IF;
		--}
		END IF;
	        --
	        --
                --x_layer_table(x_layer_table.COUNT+1) := l_layer_rec;
                g_layer_Tbl(l_layerTblCount) := l_layer_rec;
		--
		l_layerTblCount := l_layerTblCount + 1;
            --}
            END LOOP;
	--}
	END IF;
	--
	--
	/* DEbug info.
	dbms_output.put_line('g_programUnit_Tbl.Count='||g_programUnit_Tbl.COUNT);
	dbms_output.put_line('g_programUnitExt_Tbl.Count='||g_programUnitExt_Tbl.COUNT);
	dbms_output.put_line('g_layer_Tbl.Count='||g_layer_Tbl.COUNT);
	--
	--
	IF g_programUnitExt_Tbl.COUNT > 0
	THEN
	    dbms_output.put_line('g_programUnitExt_Tbl Contents');
	    l_index := g_programUnitExt_Tbl.FIRST;
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
	    --{
	        dbms_output.put_line('At Index ' || l_index || '-->'
				     || g_programUnitExt_Tbl(l_index).program_unit_id
				     || ','
				     || g_programUnitExt_Tbl(l_index).start_position);
		--
		--
		l_index := g_programUnitExt_Tbl.NEXT(l_index);
	    --}
	    END LOOP;
	END IF;
	--
	--
	IF g_programUnit_Tbl.COUNT > 0
	THEN
	    dbms_output.put_line('g_programUnit_Tbl Contents');
	    l_index := g_programUnit_Tbl.FIRST;
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
	    --{
	        dbms_output.put_line('At Index ' || l_index || '-->'
				     || g_programUnit_Tbl(l_index).program_unit_id
				     || ','
				     || g_programUnit_Tbl(l_index).start_position);
		--
		--
		l_index := g_programUnit_Tbl.NEXT(l_index);
	    --}
	    END LOOP;
	END IF;
	--
	--
	IF g_layer_Tbl.COUNT > 0
	THEN
	    dbms_output.put_line('g_layer_Tbl Contents');
	    l_index := g_layer_Tbl.FIRST;
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
	    --{
		--
		IF g_layer_tbl(l_index).is_layer_active
		THEN
	        dbms_output.put_line('At Index ' || l_index || '-->'
				     || g_layer_Tbl(l_index).layer_id
				     || ','
				     || g_layer_Tbl(l_index).layer_provider_code
	                             || ',layer is active' );
		ELSE
	        dbms_output.put_line('At Index ' || l_index || '-->'
				     || g_layer_Tbl(l_index).layer_id
				     || ','
				     || g_layer_Tbl(l_index).layer_provider_code
	                             || ',layer is not active' );
		END IF;
		--
		l_index := g_layer_Tbl.NEXT(l_index);
	    --}
	    END LOOP;
	END IF;
	*/
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END populateLayerActiveTable;
    --
    --
    /*========================================================================

       PROCEDURE NAME: isLayerActive

       PURPOSE: Returns true, if layer is active.
		It searches for the specified layer in the layer cache
		and returns active/inactive status as in the layer cache.
		It returns TRUE, if layer is active and FALSE otherwise.

		If specifed layer is not found, it returns FALSE, meaning
		that layer is inactive.

    ========================================================================*/
    FUNCTION  isLayerActive
    (
      p_layer_table          IN   g_layer_tbl_type,
      p_layer_id             IN   vea_layers.layer_id%TYPE,
      p_layer_provider_code  IN   vea_program_units.layer_provider_code%TYPE
    )
    RETURN  BOOLEAN
    IS
    --{
        l_index NUMBER;
    --}
    BEGIN
    --{
        l_index := g_layer_Tbl.FIRST;
        --
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
            IF  g_layer_Tbl(l_index).layer_id            = p_layer_id
            AND g_layer_Tbl(l_index).layer_provider_code = p_layer_provider_code
            THEN
            --{
                RETURN (g_layer_Tbl(l_index).is_layer_active);
            --}
            END IF ;
            --
            --
            l_index := g_layer_Tbl.NEXT(l_index);
        --}
        END LOOP;
        --
        --
        RETURN (FALSE);
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  isLayerActive;
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_ece_xref_category

       PURPOSE: Inserts a code conversion category into EDI table
		ECE_XREF_CATEGORIES.

    ========================================================================*/
    PROCEDURE insert_ece_xref_category
      (
	p_category_id      IN   ece_xref_categories.xref_category_id%TYPE,
	p_category_code    IN ece_xref_categories.xref_category_code%TYPE,
	p_description      IN ece_xref_categories.description%TYPE
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'insert_ece_xref_category';
        l_location            VARCHAR2(32767);
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	INSERT INTO ece_xref_categories
	  (
	    xref_category_id,
	    xref_category_code,
	    description,
	    key1_used_flag,
	    key2_used_flag,
	    key3_used_flag,
	    key4_used_flag,
	    key5_used_flag,
	    created_by,
	    creation_date,
	    last_update_date,
	    last_updated_by,
	    last_update_login
	  )
	VALUES
	  (
	    p_category_id,
	    p_category_code,
	    p_description,
	    'Y',
	    'N',
	    'N',
	    'N',
	    'N',
	    vea_tpa_util_pvt.get_user_id,
	    SYSDATE,
	    SYSDATE,
	    vea_tpa_util_pvt.get_user_id,
	    vea_tpa_util_pvt.get_login_id
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END insert_ece_xref_category;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process_ece_xref_category

       PURPOSE: Inserts a code conversion category into EDI table
		ECE_XREF_CATEGORIES, if not existing already.

    ========================================================================*/
    FUNCTION process_ece_xref_category
      (
	p_category_code   IN ece_xref_categories.xref_category_code%TYPE,
	p_description     IN ece_xref_categories.description%TYPE DEFAULT NULL
      )
    RETURN ece_xref_categories.xref_category_id%TYPE
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'process_ece_xref_category';
        l_location            VARCHAR2(32767);
	--
	--
	l_xref_category_id    ece_xref_categories.xref_category_id%TYPE;
	--
	--
	CURSOR xref_category_cur
                 (
	           p_category_code   IN ece_xref_categories.xref_category_code%TYPE
                 )
	IS
	  SELECT xref_category_id
	  FROM   ece_xref_categories
	  WHERE  xref_category_code = p_category_code;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_xref_category_id := NULL;
	--
	--
	l_location := '0020';
	--
	FOR xref_category_rec IN xref_category_cur
				   (
	                             p_category_code   => p_category_code
				   )
	LOOP
	--{
	    l_location := '0030';
	    --
	    l_xref_category_id := xref_category_rec.xref_category_id;
	--}
	END LOOP;
	--
	--
	l_location := '0040';
	--
	IF l_xref_category_id IS NULL
	THEN
	--{
	    l_location := '0050';
	    --
	    SELECT ECE_XREF_CATEGORIES_S1.nextval
	    INTO   l_xref_category_id
	    FROM   DUAL;
	    --
	    --
	    l_location := '0060';
	    --
	    vea_tpa_util_pvt.insert_ece_xref_category
	      (
                p_category_id     => l_xref_category_id,
                p_category_code   => p_category_code,
                p_description     => p_description
	      );
	--}
	END IF;
	--
	--
	l_location := '0070';
	--
	RETURN(l_xref_category_id);
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END process_ece_xref_category;
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_ece_xref_data

       PURPOSE: Inserts a code conversion value into EDI table
		ECE_XREF_DATA.

    ========================================================================*/
    PROCEDURE insert_ece_xref_data
      (
	p_data_id         IN ece_xref_data.xref_data_id%TYPE,
	p_category_id     IN ece_xref_data.xref_category_id%TYPE,
	p_category_code   IN ece_xref_data.xref_category_code%TYPE,
	p_ext_value       IN ece_xref_data.xref_ext_value1%TYPE,
	p_key1            IN ece_xref_data.xref_key1%TYPE,
	p_description     IN ece_xref_data.description%TYPE
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'insert_ece_xref_data';
        l_location            VARCHAR2(32767);
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	INSERT INTO ece_xref_data
	  (
	    xref_data_id,
	    xref_category_id,
	    xref_category_code,
	    description,
	    xref_key1,
	    xref_int_value,
	    xref_ext_value1,
	    direction,
	    created_by,
	    creation_date,
	    last_update_date,
	    last_updated_by,
	    last_update_login
	  )
	VALUES
	  (
	    p_data_id,
	    p_category_id,
	    p_category_code,
	    p_description,
	    p_key1,
	    p_ext_value,
	    p_ext_value,
	    'BOTH',
	    vea_tpa_util_pvt.get_user_id,
	    SYSDATE,
	    SYSDATE,
	    vea_tpa_util_pvt.get_user_id,
	    vea_tpa_util_pvt.get_login_id
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END insert_ece_xref_data;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process_ece_xref_data

       PURPOSE: Inserts a code conversion value into EDI table ECE_XREF_DATA,
		if record does not existing for the correspoding category,
		layer provider code(key1) and external value(branching
		condition value). IF a record is inserted then appends a
		message to log file informing user to specify code conversion
		for the inserted record.

    ========================================================================*/
    PROCEDURE process_ece_xref_data
      (
	p_category_id     IN ece_xref_data.xref_category_id%TYPE,
	p_category_code   IN ece_xref_data.xref_category_code%TYPE,
	p_ext_value       IN ece_xref_data.xref_ext_value1%TYPE,
	p_key1            IN ece_xref_data.xref_key1%TYPE,
	p_description     IN ece_xref_data.description%TYPE  DEFAULT NULL
      )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'process_ece_xref_data';
        l_location            VARCHAR2(32767);
	--
	--
	l_xref_data_id        ece_xref_data.xref_data_id%TYPE;
	--
	--
	CURSOR xref_data_cur
                 (
	           p_category_id     IN ece_xref_data.xref_category_id%TYPE,
	           p_ext_value       IN ece_xref_data.xref_ext_value1%TYPE,
	           p_key1            IN ece_xref_data.xref_key1%TYPE
                 )
	IS
	  SELECT xref_data_id
	  FROM   ece_xref_data
	  WHERE  xref_category_id = p_category_id
	  AND    xref_ext_value1  = p_ext_value
	  AND    xref_key1        = p_key1;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_xref_data_id := NULL;
	--
	--
	l_location := '0020';
	--
	FOR xref_data_rec IN xref_data_cur
				   (
                                     p_category_id     => p_category_id,
                                     p_ext_value       => p_ext_value,
                                     p_key1            => p_key1
				   )
	LOOP
	--{
	    l_location := '0030';
	    --
	    l_xref_data_id := xref_data_rec.xref_data_id;
	--}
	END LOOP;
	--
	--
	l_location := '0040';
	--
	IF l_xref_data_id IS NULL
	THEN
	--{
	    l_location := '0050';
	    --
	    SELECT ECE_XREF_DATA_S1.nextval
	    INTO   l_xref_data_id
	    FROM   DUAL;
	    --
	    --
	    l_location := '0060';
	    --
	    vea_tpa_util_pvt.insert_ece_xref_data
	      (
                p_data_id         => l_xref_data_id,
                p_category_id     => p_category_id,
                p_category_code   => p_category_code,
                p_ext_value       => p_ext_value,
                p_key1            => p_key1,
                p_description     => p_description
	      );
	    --
	    --
	    l_location := '0070';
	    --
	    vea_tpa_util_pvt.add_message
	      (
                p_error_name      => 'VEA_LM_NEW_ECE_XREF_DATA',
                p_token1          => 'ECE_XREF_CATEGORY_CODE',
                p_value1          => p_category_code,
                p_token2          => 'EXT_VALUE',
                p_value2          => p_ext_value,
                p_token3          => 'KEY1',
                p_value3          => p_key1
	      );
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END process_ece_xref_data;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_ece_xref_category_code

       PURPOSE: Maps TPS parameter name to EDI code conversion category

    ========================================================================*/
    FUNCTION
      get_ece_xref_category_code
	(
	  p_tps_parameter_name      IN     vea_parameters.name%TYPE
	)
    RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_ece_xref_category_code';
        l_location            VARCHAR2(32767);
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF LOWER(p_tps_parameter_name) = 'x_customer_number'
	THEN
	--{
	    l_location := '0020';
	    --
	    RETURN('VEA_CUSTOMER_NUMBER');
	--}
	ELSIF LOWER(p_tps_parameter_name) = 'x_tp_group_code'
	THEN
	--{
	    l_location := '0030';
	    --
	    RETURN('VEA_TP_GROUP_CODE');
	--}
	ELSIF LOWER(p_tps_parameter_name) = 'x_ship_to_ece_locn_code'
	OR    LOWER(p_tps_parameter_name) = 'x_bill_to_ece_locn_code'
	OR    LOWER(p_tps_parameter_name) = 'x_inter_ship_to_ece_locn_code'
	THEN
	--{
	    l_location := '0040';
	    --
	    RETURN('VEA_ECE_TP_LOCATION_CODE');
	--}
	ELSE
	--{
	    RETURN(NULL);
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	    /*
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	    */
	--}
    --}
    END get_ece_xref_category_code;
    --
    --
    /*========================================================================

       PROCEDURE NAME: get_ece_xref_category_code

       PURPOSE: Maps TPS parameter to EDI code conversion category

    ========================================================================*/
    FUNCTION
      get_ece_xref_category_code
	(
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
	  p_tps_parameter_id      IN     vea_layers.tps_parameter1_id%TYPE
	)
    RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'get_ece_xref_category_code';
        l_location            VARCHAR2(32767);
	--
	--
	CURSOR parameter_cur
	         (
                   p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
                   p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
	           p_tps_parameter_id      IN     vea_layers.tps_parameter1_id%TYPE
	         )
	IS
	  SELECT PA.name
	  FROM   vea_parameters PA,
		 vea_program_units PU,
		 vea_layer_headers LH
	  WHERE  PA.parameter_id        = p_tps_parameter_id
	  AND    LH.layer_provider_code = p_layer_provider_code
	  AND    LH.layer_header_id     = p_layer_header_id
	  AND    PU.program_unit_id     = LH.tps_program_unit_id
	  AND    PU.layer_provider_code = LH.tps_program_unit_lp_code
	  AND    PA.program_unit_id     = PU.program_unit_id
	  AND    PA.layer_provider_code = PU.layer_provider_code;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR parameter_rec IN parameter_cur
	                       (
                                 p_layer_provider_code => p_layer_provider_code,
                                 p_layer_header_id     => p_layer_header_id,
	                         p_tps_parameter_id    => p_tps_parameter_id
	                       )
	LOOP
	--{
	    l_location := '0010';
	    --
	    --
	    RETURN
	      (
	        vea_tpa_util_pvt.get_ece_xref_category_code
	          (
	            p_tps_parameter_name      => parameter_rec.name
	          )
	      );
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END get_ece_xref_category_code;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process_code_conversion

       PURPOSE: Processes each branch criteria codition to check if it
		requires EDI code conversion.
		- Maps TPS parameter name to EDI code category.
		- Inserts EDI code category, if not existing already.
		- Inserts EDI code conversion value, if not existing already.

		This procedure is called during layer merge.

    ========================================================================*/
    PROCEDURE
      process_code_conversion
	(
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
	  p_tps_parameter_id      IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter_value   IN     vea_layers.tps_parameter1_value%TYPE
	)
    IS
    --{
        l_api_name               CONSTANT VARCHAR2(30) := 'process_code_conversion';
        l_location               VARCHAR2(32767);
	--
	--
	l_ece_xref_category_code ece_xref_categories.xref_category_code%TYPE;
	l_xref_category_id       ece_xref_categories.xref_category_id%TYPE;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_tps_parameter_id IS NOT NULL
	AND p_tps_parameter_value IS NOT NULL
	THEN
	--{
	    l_location := '0020';
	    --
	    l_ece_xref_category_code
	    :=
	    vea_tpa_util_pvt.get_ece_xref_category_code
	      (
                p_layer_provider_code   => p_layer_provider_code,
                p_layer_header_id       => p_layer_header_id,
	        p_tps_parameter_id      => p_tps_parameter_id
	      );
	--}
	END IF;
	--
	--
	l_location := '0030';
	--
	IF l_ece_xref_category_code IS NOT NULL
	THEN
	--{
	    l_location := '0040';
	    --
	    l_xref_category_id
	    :=
	    vea_tpa_util_pvt.process_ece_xref_category
	      (
	        p_category_code      => l_ece_xref_category_code
	      );
	    --
	    --
	    l_location := '0050';
	    --
	    vea_tpa_util_pvt.process_ece_xref_data
	      (
	        p_category_id     => l_xref_category_id,
	        p_category_code   => l_ece_xref_category_code,
                p_key1            => p_layer_provider_code,
	        p_ext_value       => p_tps_parameter_value
	      );
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END process_code_conversion;
    --
    --
    /*========================================================================

       PROCEDURE NAME: convertBranchCriteria

       PURPOSE: Converts branch condition values to internal values.

		This procedure is called during execution of TPA generated
		code.

    ========================================================================*/
    FUNCTION  convertBranchCriteria
    (
      p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
      p_parameter_name       IN      vea_parameters.name%TYPE,
      p_external_value       IN      ece_xref_data.xref_ext_value1%TYPE,
      x_code_conversion_tbl  IN OUT NOCOPY   vea_tpa_util_pvt.g_code_conversion_tbl_type
    )
    RETURN  ece_xref_data.xref_int_value%TYPE
    IS
    --{
        l_index NUMBER;
	--
	--
        l_parameter_name         vea_parameters.name%TYPE;
	l_ece_xref_category_code ece_xref_categories.xref_category_code%TYPE;
	l_code_conversion_rec    vea_tpa_util_pvt.g_code_conversion_rec_type;
        l_internal_value         ece_xref_data.xref_int_value%TYPE;
	--
	--
	l_return_status   VARCHAR2(32767);
	l_msg_count       NUMBER;
	l_msg_data        VARCHAR2(32767);
	l_msg_index       NUMBER;
	l_message         VARCHAR2(32767);
    --}
    BEGIN
    --{
        l_index := x_code_conversion_tbl.FIRST;
        --
        --
	l_parameter_name := LOWER(p_parameter_name);
        --
        --
        WHILE l_index IS NOT NULL
        LOOP
        --{
	    l_code_conversion_rec := x_code_conversion_tbl(l_index);
	    --
	    --
            IF  l_code_conversion_rec.parameter_name      = l_parameter_name
            AND l_code_conversion_rec.layer_provider_code = p_layer_provider_code
	    AND l_code_conversion_rec.external_value      = p_external_value
            THEN
            --{
                RETURN (l_code_conversion_rec.internal_value);
            --}
	    END IF;
            --
            --
            l_index := x_code_conversion_tbl.NEXT(l_index);
        --}
        END LOOP;
	--
	--
	l_ece_xref_category_code
	:=
	vea_tpa_util_pvt.get_ece_xref_category_code
	  (
	    p_tps_parameter_name   => l_parameter_name
	  );
	--
	--
	IF l_ece_xref_category_code IS NULL
	THEN
	--{
	    RETURN(p_external_value);
	--}
	END IF;
	--
	--
	EC_Code_Conversion_PVT.Convert_from_ext_to_int
	  (
	    p_api_version_number => 1.0,
	    p_return_status      => l_return_status,
	    p_msg_count          => l_msg_count,
	    p_msg_data           => l_msg_data,
	    p_Category           => l_ece_xref_category_code,
	    p_Key1               => p_layer_provider_code,
	    p_Int_val            => l_internal_value,
	    p_Ext_val1           => p_external_value
	  );
	 --
	 --
	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	 THEN
	 --{
	     l_code_conversion_rec.parameter_name      := l_parameter_name;
	     l_code_conversion_rec.layer_provider_code := p_layer_provider_code;
	     l_code_conversion_rec.external_value      := p_external_value;
	     l_code_conversion_rec.internal_value      := l_internal_value;
	     --
	     --
	     x_code_conversion_tbl(x_code_conversion_tbl.COUNT+1)
	     := l_code_conversion_rec;
	     --
	     --
	     RETURN(l_internal_value);
	 --}
	 ELSE
	 --{
	     IF l_msg_count = 1
	     THEN
	     --{
		 l_message := l_msg_data;
	     --}
	     ELSE
	     --{
                 FOR l_msg_index IN 1..l_msg_count
                 LOOP
                 --{
		     l_message := SUBSTRB
				    (
				      l_message
				      || ' '
				      || FND_MSG_PUB.GET
				           (
				             p_encoded => FND_API.G_FALSE
				           ),
				      1,
				      32767
				    );
		 --}
		 END LOOP;
	     --}
	     END IF;
	     --
	     --
	     set_message
	       (
		 p_error_name => 'VEA_CODE_CONVERSION_ERROR',
		 p_token1     => 'ECE_XREF_CATEGORY_CODE',
		 p_value1     => l_ece_xref_category_code,
		 p_token2     => 'EXT_VALUE',
		 p_value2     => p_external_value,
		 p_token3     => 'KEY1',
		 p_value3     => p_layer_provider_code,
		 p_token4     => 'ERROR_TEXT',
		 p_value4     => l_message
	       );
	     --
	     --
	     APP_EXCEPTION.RAISE_EXCEPTION;
	 --}
	 END IF;
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  convertBranchCriteria;
    --
    --
    /*========================================================================

       PROCEDURE NAME: Convert_from_ext_to_int

       PURPOSE: Cover API for ECE code conversion API

    ========================================================================*/
    FUNCTION  Convert_from_ext_to_int
    (
      p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
      p_parameter_name       IN      vea_parameters.name%TYPE,
      p_external_value       IN      ece_xref_data.xref_ext_value1%TYPE
    )
    RETURN  ece_xref_data.xref_int_value%TYPE
    IS
    --{
        l_parameter_name         vea_parameters.name%TYPE;
	l_ece_xref_category_code ece_xref_categories.xref_category_code%TYPE;
        l_external_value         ece_xref_data.xref_ext_value1%TYPE;
        l_external_value2        ece_xref_data.xref_ext_value2%TYPE;
        l_external_value3        ece_xref_data.xref_ext_value3%TYPE;
        l_external_value4        ece_xref_data.xref_ext_value4%TYPE;
        l_external_value5        ece_xref_data.xref_ext_value5%TYPE;
        l_internal_value         ece_xref_data.xref_int_value%TYPE;
	--
	--
	l_return_status   VARCHAR2(32767);
	l_msg_count       NUMBER;
	l_msg_data        VARCHAR2(32767);
	l_msg_index       NUMBER;
	l_message         VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_parameter_name := LOWER(p_parameter_name);
        --
        --
	l_ece_xref_category_code
	:=
	vea_tpa_util_pvt.get_ece_xref_category_code
	  (
	    p_tps_parameter_name   => l_parameter_name
	  );
	--
	--
	IF l_ece_xref_category_code IS NULL
	THEN
	--{
	    RETURN(p_external_value);
	--}
	END IF;
	--
	--
	EC_Code_Conversion_PVT.Convert_from_ext_to_int
	  (
	    p_api_version_number => 1.0,
	    p_return_status      => l_return_status,
	    p_msg_count          => l_msg_count,
	    p_msg_data           => l_msg_data,
	    p_Category           => l_ece_xref_category_code,
	    p_Key1               => p_layer_provider_code,
	    p_Int_val            => l_internal_value,
	    p_Ext_val1           => p_external_value
	  );
	 --
	 --
	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	 THEN
	 --{
	     RETURN(l_internal_value);
	 --}
	 ELSE
	 --{
	     IF l_msg_count = 1
	     THEN
	     --{
		 l_message := l_msg_data;
	     --}
	     ELSE
	     --{
                 FOR l_msg_index IN 1..l_msg_count
                 LOOP
                 --{
		     l_message := SUBSTRB
				    (
				      l_message
				      || ' '
				      || FND_MSG_PUB.GET
				           (
				             p_encoded => FND_API.G_FALSE
				           ),
				      1,
				      32767
				    );
		 --}
		 END LOOP;
	     --}
	     END IF;
	     --
	     --
	     set_message
	       (
		 p_error_name => 'VEA_CODE_CONVERSION_ERROR',
		 p_token1     => 'ECE_XREF_CATEGORY_CODE',
		 p_value1     => l_ece_xref_category_code,
		 p_token2     => 'EXT_VALUE',
		 p_value2     => p_external_value,
		 p_token3     => 'KEY1',
		 p_value3     => p_layer_provider_code,
		 p_token4     => 'ERROR_TEXT',
		 p_value4     => l_message
	       );
	     --
	     --
	     APP_EXCEPTION.RAISE_EXCEPTION;
	 --}
	 END IF;
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  Convert_from_ext_to_int;
    --
    --
    /*========================================================================

       PROCEDURE NAME: Convert_from_int_to_ext

       PURPOSE: Cover API for ECE code conversion API

    ========================================================================*/
    FUNCTION  Convert_from_int_to_ext
    (
      p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
      p_parameter_name       IN      vea_parameters.name%TYPE,
      p_internal_value       IN      ece_xref_data.xref_int_value%TYPE
    )
    RETURN  ece_xref_data.xref_ext_value1%TYPE
    IS
    --{
        l_parameter_name         vea_parameters.name%TYPE;
	l_ece_xref_category_code ece_xref_categories.xref_category_code%TYPE;
        l_external_value         ece_xref_data.xref_ext_value1%TYPE;
        l_external_value2        ece_xref_data.xref_ext_value2%TYPE;
        l_external_value3        ece_xref_data.xref_ext_value3%TYPE;
        l_external_value4        ece_xref_data.xref_ext_value4%TYPE;
        l_external_value5        ece_xref_data.xref_ext_value5%TYPE;
	--
	--
	l_return_status   VARCHAR2(32767);
	l_msg_count       NUMBER;
	l_msg_data        VARCHAR2(32767);
	l_msg_index       NUMBER;
	l_message         VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_parameter_name := LOWER(p_parameter_name);
        --
        --
	l_ece_xref_category_code
	:=
	vea_tpa_util_pvt.get_ece_xref_category_code
	  (
	    p_tps_parameter_name   => l_parameter_name
	  );
	--
	--
	IF l_ece_xref_category_code IS NULL
	THEN
	--{
	    RETURN(p_internal_value);
	--}
	END IF;
	--
	--
	EC_Code_Conversion_PVT.Convert_from_int_to_ext
	  (
	    p_api_version_number => 1.0,
	    p_return_status      => l_return_status,
	    p_msg_count          => l_msg_count,
	    p_msg_data           => l_msg_data,
	    p_Category           => l_ece_xref_category_code,
	    p_Key1               => p_layer_provider_code,
	    p_Int_val            => p_internal_value,
	    p_Ext_val1           => l_external_value,
	    p_Ext_val2           => l_external_value2,
	    p_Ext_val3           => l_external_value3,
	    p_Ext_val4           => l_external_value4,
	    p_Ext_val5           => l_external_value5
	  );
	 --
	 --
	 IF l_return_status = FND_API.G_RET_STS_SUCCESS
	 THEN
	 --{
	     RETURN(l_external_value);
	 --}
	 ELSE
	 --{
	     IF l_msg_count = 1
	     THEN
	     --{
		 l_message := l_msg_data;
	     --}
	     ELSE
	     --{
                 FOR l_msg_index IN 1..l_msg_count
                 LOOP
                 --{
		     l_message := SUBSTRB
				    (
				      l_message
				      || ' '
				      || FND_MSG_PUB.GET
				           (
				             p_encoded => FND_API.G_FALSE
				           ),
				      1,
				      32767
				    );
		 --}
		 END LOOP;
	     --}
	     END IF;
	     --
	     --
	     set_message
	       (
		 p_error_name => 'VEA_CODE_CONVERSION_ERROR',
		 p_token1     => 'ECE_XREF_CATEGORY_CODE',
		 p_value1     => l_ece_xref_category_code,
		 p_token2     => 'INT_VALUE',
		 p_value2     => p_internal_value,
		 p_token3     => 'KEY1',
		 p_value3     => p_layer_provider_code,
		 p_token4     => 'ERROR_TEXT',
		 p_value4     => l_message
	       );
	     --
	     --
	     APP_EXCEPTION.RAISE_EXCEPTION;
	 --}
	 END IF;
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  Convert_from_int_to_ext;
    --
    --
    PROCEDURE  debug
    (
      p_string  IN      VARCHAR2
    )
    IS
    --{
    --}
    BEGIN
    --{
        FND_FILE.PUT_LINE(FND_FILE.LOG,p_string);
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  debug;
    --
    --
    FUNCTION  validate
    RETURN BOOLEAN
    IS
    --{
    --}
    BEGIN
    --{
        RETURN (TRUE);
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  validate;
    --
    --
/*========================================================================

       PROCEDURE NAME: get_message_text

       PURPOSE: Returns a message to the Application

       Added by V RAVIKIRAN 10/12/2000
    ========================================================================*/

    --
    --
    FUNCTION get_message_text
    (
        p_error_name  IN      VARCHAR2,
        p_token1      IN      VARCHAR2 ,
        p_value1      IN      VARCHAR2 ,
        p_token2      IN      VARCHAR2 ,
        p_value2      IN      VARCHAR2 ,
        p_token3      IN      VARCHAR2 ,
        p_value3      IN      VARCHAR2 ,
        p_token4      IN      VARCHAR2 ,
        p_value4      IN      VARCHAR2 ,
        p_token5      IN      VARCHAR2 ,
        p_value5      IN      VARCHAR2 ,
        p_token6      IN      VARCHAR2 ,
        p_value6      IN      VARCHAR2 ,
        p_token7      IN      VARCHAR2 ,
        p_value7      IN      VARCHAR2 ,
        p_token8      IN      VARCHAR2 ,
        p_value8      IN      VARCHAR2

    )
    RETURN VARCHAR2
    IS
    --{
       l_api_name            CONSTANT VARCHAR2(30) := 'get_message_text';
       l_location            VARCHAR2(32767);
    --}
    BEGIN
    --{
        l_location := '0010';
       --
       --
       vea_tpa_util_pvt.set_message
              (
                p_error_name => p_error_name,
                p_token1     => p_token1,
                p_value1     => p_value1,
                p_token2     => p_token2,
                p_value2     => p_value2,
                p_token3     => p_token3,
                p_value3     => p_value3,
                p_token4     => p_token4,
                p_value4     => p_value4,
                p_token5     => p_token5,
                p_value5     => p_value5,
                p_token6     => p_token6,
                p_value6     => p_value6,
                p_token7     => p_token7,
                p_value7     => p_value7,
                p_token8     => p_token8,
                p_value8     => p_value8
              );
       --
       --
        l_location := '0020';
       --
       --
       RETURN(FND_MESSAGE.GET);
       --
       --
       EXCEPTION
       --{
          WHEN OTHERS
          THEN
	      RAISE;
       --}
    END get_message_text;
    --
    --
    PROCEDURE update_lookup_values
    (
        p_lookup_type         IN    fnd_lookup_values.lookup_type%TYPE,
        p_new_lookup_code     IN    fnd_lookup_values.lookup_code%TYPE,
        p_current_lookup_code IN    fnd_lookup_values.lookup_code%TYPE,
        p_meaning             IN    fnd_lookup_values.meaning%TYPE,
        p_description         IN    fnd_lookup_values.description%TYPE
    )
    IS
     --{
         l_api_name            CONSTANT VARCHAR2(30) := 'update_lookup_values';
         l_location            VARCHAR2(32767);
         l_row_id	       VARCHAR2(55);
     --}
    BEGIN
    --{
        l_location := '0010';
        --
        --
        UPDATE fnd_lookup_values
        SET lookup_code     =   p_new_lookup_code,
            meaning         =   p_meaning,
            description     =   p_description
        WHERE lookup_type   =   p_lookup_type
        AND   lookup_code   =   p_current_lookup_code;
        --
        --
   EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
    --}
    END update_lookup_values;
    --
    --
    PROCEDURE insert_lookup_values
    (
        p_lookup_type         IN    fnd_lookup_values.lookup_type%TYPE,
        p_lookup_code         IN    fnd_lookup_values.lookup_code%TYPE,
        p_meaning             IN    fnd_lookup_values.meaning%TYPE,
        p_description         IN    fnd_lookup_values.description%TYPE
    )
    IS
     --{
         l_api_name            CONSTANT VARCHAR2(30) := 'insert_lookup_values';
         l_location            VARCHAR2(32767);
         l_row_id              VARCHAR2(55);
     --}
    BEGIN
    --{
        l_location := '0010';
        --
        --
        FND_LOOKUP_VALUES_PKG.INSERT_ROW
          (
            x_rowid                  => l_row_id,
            x_lookup_type            => p_lookup_type,
            x_security_group_id      => FND_GLOBAL.SECURITY_GROUP_ID,
            x_view_application_id    => 0,
            x_lookup_code            => p_lookup_code,
            x_tag                    => NULL,
            x_attribute_category     => NULL,
            x_attribute1             => NULL,
            x_attribute2             => NULL,
            x_attribute3             => NULL,
            x_attribute4             => NULL,
            x_enabled_flag           => 'Y',
            x_start_date_active      => SYSDATE,
            x_end_date_active        => NULL,
            x_territory_code         => NULL,
            x_attribute5             => NULL,
            x_attribute6             => NULL,
            x_attribute7             => NULL,
            x_attribute8             => NULL,
            x_attribute9             => NULL,
            x_attribute10            => NULL,
            x_attribute11            => NULL,
            x_attribute12            => NULL,
            x_attribute13            => NULL,
            x_attribute14            => NULL,
            x_attribute15            => NULL,
            x_meaning                => p_meaning,
            x_description            => p_description,
            x_creation_date          => SYSDATE,
            x_created_by             => FND_GLOBAL.USER_ID,
            x_last_update_date       => SYSDATE,
            x_last_updated_by        => FND_GLOBAL.USER_ID,
            x_last_update_login      => FND_GLOBAL.LOGIN_ID
          );
        --
        --
   EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
    --}
    END insert_lookup_values;


    --
    --
    /*========================================================================

       PROCEDURE NAME: clearLayerActiveTable

    ========================================================================*/
    PROCEDURE
      clearLayerActiveTable
    IS
    --{
    --}
    BEGIN
    --{
	    g_programUnit_Tbl.DELETE;
	    g_programUnitExt_Tbl.DELETE;
	    g_layer_Tbl.DELETE;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END clearLayerActiveTable;
    --
    --

    --
    --
    /*========================================================================

       PROCEDURE NAME: put

    ========================================================================*/
    PROCEDURE
      put
        (
	  p_key                IN            NUMBER,
	  p_value              IN            NUMBER,
	  x_cache_tbl          IN OUT NOCOPY g_cache_tbl_type,
	  x_cache_ext_tbl      IN OUT NOCOPY g_cache_tbl_type
	)
    IS
    --{
        l_index NUMBER;
	l_found BOOLEAN := FALSE;
    --}
    BEGIN
    --{
        IF p_key IS NULL
	THEN
            RAISE FND_API.G_EXC_ERROR;
	END IF;
	--
	--
	IF p_key < C_INDEX_LIMIT
	THEN
	    x_cache_tbl(p_key).key   := p_key;
	    x_cache_tbl(p_key).value := p_value;
	ELSE
	    l_index := x_cache_ext_tbl.FIRST;
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
               IF x_cache_ext_tbl(l_index).key = p_key
	       THEN
	           x_cache_ext_tbl(l_index).value := p_value;
		   l_found := TRUE;
		   EXIT;
	       END IF;
	       --
	       l_index := x_cache_ext_tbl.NEXT(l_index);
	    END LOOP;
	    --
	    IF NOT(l_found)
	    THEN
              x_cache_ext_tbl(x_cache_ext_tbl.COUNT + 1).key := p_key;
              x_cache_ext_tbl(x_cache_ext_tbl.COUNT).value := p_value;
	    END IF;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END put;
    --
    --
    --
    /*========================================================================

       PROCEDURE NAME: get

    ========================================================================*/
    PROCEDURE
      get
        (
	  p_key                IN            NUMBER,
	  p_cache_tbl          IN OUT NOCOPY g_cache_tbl_type,
	  p_cache_ext_tbl      IN OUT NOCOPY g_cache_tbl_type,
	  x_value              OUT    NOCOPY NUMBER
	)
    IS
    --{
        l_index NUMBER;
	l_found BOOLEAN := FALSE;
    --}
    BEGIN
    --{
        IF p_key IS NULL
	THEN
          RAISE FND_API.G_EXC_ERROR;
	END IF;
	--
	--
	IF p_key < C_INDEX_LIMIT
	THEN
            IF p_cache_tbl.EXISTS(p_key)
	    THEN
	       x_value := p_cache_tbl(p_key).value;
	    ELSE
               RAISE FND_API.G_EXC_ERROR;
	    END IF;
	ELSE
	    l_index := p_cache_ext_tbl.FIRST;
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
               IF p_cache_ext_tbl(l_index).key = p_key
	       THEN
		   x_value := p_cache_ext_tbl(l_index).value ;
		   l_found := TRUE;
		   EXIT;
	       END IF;
	       --
	       l_index := p_cache_ext_tbl.NEXT(l_index);
	    END LOOP;
	    --
	    IF NOT(l_found)
	    THEN
               RAISE FND_API.G_EXC_ERROR;
	    END IF;
	END IF;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END get;
    --
    --

--}
END VEA_TPA_UTIL_PVT;

/
