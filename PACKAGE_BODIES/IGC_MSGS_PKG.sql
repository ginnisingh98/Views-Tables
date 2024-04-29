--------------------------------------------------------
--  DDL for Package Body IGC_MSGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_MSGS_PKG" AS
/* $Header: IGCBMSGB.pls 120.4.12000000.1 2007/08/20 12:10:13 mbremkum ship $ */

-- Private Global Variables :

g_pkg_name         CONSTANT VARCHAR2(30) := 'IGC_MSGS_PKG';
g_filename         VARCHAR2(255) := NULL;
g_dirpath          VARCHAR2(255) := NULL;
g_file_ptr         UTL_FILE.FILE_TYPE;

PROCEDURE Initialize_Debug (
   p_profile_name     IN VARCHAR2,
   p_product          IN VARCHAR2,
   p_sub_component    IN VARCHAR2,
   p_filename_value   IN VARCHAR2 := NULL,
   x_Return_Status   OUT NOCOPY VARCHAR2
);


-- Procedure that adds the appropriate message to the Token array that will be added
-- to the error stack so that the user can see any messages generated from the process
-- being run.
--
-- Parameters :
--
-- p_tokname        ==> Token name of the error message
-- p_tokval         ==> Value of the token to be added.
--

PROCEDURE message_token(
   p_tokname           IN VARCHAR2,
   p_tokval            IN VARCHAR2
) IS

BEGIN

   IF (g_no_msg_tokens IS NULL) THEN
      g_no_msg_tokens := 1;
   ELSE
      g_no_msg_tokens := g_no_msg_tokens + 1;
   END IF;

   g_msg_tok_names (g_no_msg_tokens) := p_tokname;
   g_msg_tok_val (g_no_msg_tokens)   := p_tokval;

END message_token;


--
-- Procedure that sets/adds the appropriate message to the error stack so that the
-- user can see any messages generated from the process being run.
--
-- Parameters :
--
-- p_appname        ==> Application name used for message
-- p_msgname        ==> Message to be added onto message stack
--

PROCEDURE add_message(
   p_appname           IN VARCHAR2,
   p_msgname           IN VARCHAR2
) IS

i  BINARY_INTEGER;

BEGIN

   IF ((p_appname IS NOT NULL) and (p_msgname IS NOT NULL)) THEN

      FND_MESSAGE.SET_NAME (p_appname, p_msgname);

      IF (g_no_msg_tokens IS NOT NULL) THEN

         FOR i IN 1..g_no_msg_tokens LOOP
            FND_MESSAGE.SET_TOKEN (g_msg_tok_names(i), g_msg_tok_val(i));
         END LOOP;

      END IF;

      FND_MSG_PUB.ADD;

    END IF;

    -- Clear Message Token stack

    g_no_msg_tokens := 0;

END add_message;

--
-- Procedure that initializes the debug file and updates the appropriate variables that
-- are required for the next call to the Put_Debug_Msg.  These variables should be
-- defined as globals in the callers packages.
--
-- Parameters :
--
-- p_profile_name      ==> Profile option used to get directory location for debug
-- p_product           ==> Product string (IGC, GMS, etc.)
-- p_sub_component     ==> Sub Component name to the product (CC, CBC, etc.)
-- p_filename_value    ==> If NULL then build here otherwise use callers filename.
-- x_Return_Status     ==> Status of procedure returned to caller
--

PROCEDURE Initialize_Debug (
   p_profile_name     IN VARCHAR2,
   p_product          IN VARCHAR2,
   p_sub_component    IN VARCHAR2,
   p_filename_value   IN VARCHAR2 := NULL,
   x_Return_Status   OUT NOCOPY VARCHAR2
) IS

   l_api_name             CONSTANT VARCHAR2(30)   := 'Initialize_Debug';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF ( (p_filename_value IS NULL) AND
        ((p_product IS NULL) OR
         (p_sub_component IS NULL)) ) THEN

      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode    := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_NO_PROD_COMP'
                               );

   ELSE

-- ----------------------------------------------------------------------
-- Build the filename and directory location that is to be used for the
-- debug output.
-- ----------------------------------------------------------------------
      IF (p_filename_value IS NULL) THEN
         g_filename := LTRIM (RTRIM (p_product)) || '_' || LTRIM (RTRIM (p_sub_component)) ||
                       '_' || USERENV ('SESSIONID') || '.dbg';
      ELSE
         g_filename := p_filename_value;
      END IF;
      g_dirpath  := FND_PROFILE.VALUE (p_profile_name);

-- ----------------------------------------------------------------------
-- Since the directory location for the debug output for UTL_FILE has
-- not been setup from the user the utility will not work properly.
-- Set the global Debug mode flag to false and return with error message
-- added.
-- ----------------------------------------------------------------------
      IF (g_dirpath IS NULL) THEN

         x_return_status := FND_API.G_RET_STS_ERROR;
         --g_debug_mode    := FALSE;
         IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                   p_msgname => 'IGC_DEBUG_NO_PROFILE_PATH'
                                  );

      ELSE

-- ----------------------------------------------------------------------
-- Make sure that the file is not open currently.  If it is close the
-- file before reopening.
-- ----------------------------------------------------------------------
         IF (UTL_FILE.IS_OPEN ( g_file_ptr )) THEN
            UTL_FILE.FCLOSE ( g_file_ptr );
         END IF;

-- ----------------------------------------------------------------------
-- Assign the global pointer to be used for the debug output.
-- ----------------------------------------------------------------------
         g_file_ptr := UTL_FILE.FOPEN ( g_dirpath, g_filename, 'a' );

      END IF;

   END IF;

   RETURN;

-- ----------------------------------------------------------------------
-- Exception section for the Initialize_Debug procedure.
-- ----------------------------------------------------------------------
EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode    := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_INVALID_PATH'
                               );
      RETURN;

   WHEN UTL_FILE.WRITE_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode    := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_WRITE_ERROR'
                               );
      RETURN;

   WHEN UTL_FILE.INVALID_FILEHANDLE  THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode    := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_FILEHANDLE'
                               );
      RETURN;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode    := FALSE;
      IF (FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )) THEN
         FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
      END IF;
      RETURN;

END Initialize_Debug;

--
-- Procedure that outputs debug message to debug file that has been initialized and
-- created.
--
-- Parameters :
--
-- p_debug_message     ==> Message to be output to debug file.
-- p_profile_log_name  ==> Profile option used to get directory location for debug
-- p_prod              ==> Product string (IGC, GMS, etc.)
-- p_sub_comp          ==> Sub Component name to the product (CC, CBC, etc.)
-- p_filename_val      ==> If NULL then build in initialize otherwise use the callers value.
-- x_Return_Status     ==> Status of procedure returned to caller

PROCEDURE Put_Debug_Msg (
   p_debug_message        IN VARCHAR2,
   p_profile_log_name     IN VARCHAR2,
   p_prod                 IN VARCHAR2,
   p_sub_comp             IN VARCHAR2,
   p_filename_val         IN VARCHAR2 := NULL,
   x_Return_Status       OUT NOCOPY VARCHAR2
) IS

   l_dir_loc        VARCHAR2(255);
   l_filename       VARCHAR2(255);
   l_file_ptr       UTL_FILE.FILE_TYPE;
   l_Return_Status  VARCHAR2(1);
   l_debug_mode     BOOLEAN;

   l_api_name       CONSTANT VARCHAR2(30)   := 'Put_Debug_Msg';

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

-- -----------------------------------------------------------------------
-- Make sure that Debug is actually turned on from the call to the main
-- procedure and that there is a designated directory path for the file.
-- Commenting the IF as calling procedures should check and then make
-- a call to this procedure.19 Nov 2002
-- -----------------------------------------------------------------------
--   IF (g_debug_mode) THEN

-- -----------------------------------------------------------------------
-- Ensure that there is content to the message that is to be placed into
-- the Debug file.
-- -----------------------------------------------------------------------
      IF (p_debug_message IS NOT NULL) THEN

-- -----------------------------------------------------------------------
-- Make sure that the initialize routine has been called.  The file should
-- be open, file name build and it is not null.  If either of these cases
-- is TRUE then the Initialize routine should be called.
-- -----------------------------------------------------------------------
         IF ( ( NOT UTL_FILE.IS_OPEN (g_file_ptr) ) OR
              ( g_filename IS NULL ) OR
              ( g_dirpath  IS NULL )) THEN

            Initialize_Debug (p_profile_name  => p_profile_log_name,
                              p_product       => p_prod,
                              p_sub_component => p_sub_comp,
                              p_filename_value => p_filename_val,
                              x_Return_Status => l_return_status
                             );

            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END IF;

-- -----------------------------------------------------------------------
-- Output Debug message to file and flush the output.
-- -----------------------------------------------------------------------
            UTL_FILE.PUT_LINE ( g_file_ptr, p_debug_message );
            UTL_FILE.FFLUSH ( g_file_ptr );

      END IF;

 --  END IF;

   RETURN;

-- ----------------------------------------------------------------------
-- Exception section for the Put_Debug_Msg procedure.
-- ----------------------------------------------------------------------
EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_INVALID_PATH'
                               );
      RETURN;

   WHEN UTL_FILE.WRITE_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_WRITE_ERROR'
                               );
      RETURN;

   WHEN UTL_FILE.INVALID_FILEHANDLE  THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode := FALSE;
      IGC_MSGS_PKG.add_message (p_appname => 'IGC',
                                p_msgname => 'IGC_DEBUG_FILEHANDLE'
                               );
      RETURN;

   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      --g_debug_mode := FALSE;
      IF (FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR )) THEN
         FND_MSG_PUB.Add_Exc_Msg ( g_pkg_name, l_api_name );
      END IF;
      RETURN ;

END Put_Debug_Msg;


END IGC_MSGS_PKG;


/
