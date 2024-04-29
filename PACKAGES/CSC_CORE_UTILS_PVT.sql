--------------------------------------------------------
--  DDL for Package CSC_CORE_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_CORE_UTILS_PVT" AUTHID CURRENT_USER as
/* $Header: cscvcors.pls 115.19 2002/12/04 19:13:10 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_CORE_UTILS_PVT
-- Purpose          : This package contains all the common procedure, functions and global
--                    variables that will be used by the CUSTOMER CARE-MODULE.
-- History
-- MM-DD-YYYY    NAME          MODIFICATION
-- 13-08-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 05-04-2000    dejoseph      Included procedure to gather CBO statistics on a given
--                             table.
-- 02-22-2001    dejoseph      Added two more plan status functions, MERGE_PLAN and
--                             TRANSFER_PLAN for the purpose of Party Merge.
-- 12-03-2002    jamose        Added function for Fnd_Api_G_Miss* Changes
-- End of Comments


G_PVT             CONSTANT   VARCHAR2(30):= '_PVT';
G_PUB             CONSTANT   VARCHAR2(30):= '_PUB';

G_APP_SHORTNAME   CONSTANT   VARCHAR2(5) := 'CSC';
--G_UPDATE          CONSTANT   VARCHAR2(6) := 'UPDATE';
--G_CREATE          CONSTANT   VARCHAR2(6) := 'CREATE';

L_UPDATE          CONSTANT   VARCHAR2(6) := 'UPDATE';
L_CREATE          CONSTANT   VARCHAR2(6) := 'CREATE';

G_PKG_NAME        CONSTANT   VARCHAR2(30):= 'CSC_CORE_UTILS_PVT';
G_FILE_NAME       CONSTANT   VARCHAR2(12):= 'cscvcors.pls';

G_MSG_LVL_OTHERS  CONSTANT   NUMBER      := 70;
-- This level of error is used when the 'WHEN OTHERS' exception is executed.
-- This value is passed when an Oracle error has occured on the server side which cannot
-- be trapped under normal validations, like value to large to be inserte/updated into
-- a column etc. The other error levels being used are taken from the FND_MSG_PUB package.

CURSOR g_lookups ( c_lookup_type VARCHAR2,
			    c_lookup_code VARCHAR2 ) IS
SELECT meaning
FROM   fnd_lookups
WHERE  lookup_type = c_lookup_type
AND    lookup_code = c_lookup_code;


RECORD_LOCK_EXCEPTION EXCEPTION;
PRAGMA EXCEPTION_INIT(RECORD_LOCK_EXCEPTION,-0054);

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_CREATE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the value of the constant
   --                  CSC_CORE_UTILS_PVT.L_CREATE
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_CREATE RETURN VARCHAR2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_UPDATE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the value of the constant
   --                  CSC_CORE_UTILS_PVT.L_UPDATE
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_UPDATE RETURN VARCHAR2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_MISS_NUM
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_MISS_NUM
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_MISS_NUM RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_MISS_CHAR
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_MISS_CHAR
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION G_MISS_CHAR RETURN VARCHAR2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_MISS_DATE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_MISS_DATE
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_MISS_DATE RETURN DATE ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_RET_STS_SUCCESS
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_RET_STS_SUCCESS
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_RET_STS_SUCCESS RETURN VARCHAR2 ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_RET_STS_ERROR
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_RET_STS_ERROR
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_RET_STS_ERROR RETURN VARCHAR2 ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_RET_STS_UNEXP_ERROR
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant FND_API.G_RET_STS_UNEXP_ERROR
   --   Return Type :  Date
   --
   --   End of Comments
   --
FUNCTION G_RET_STS_UNEXP_ERROR RETURN VARCHAR2 ;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_VALID_LEVEL_NONE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_VALID_LEVEL_NONE
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_VALID_LEVEL_NONE RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_VALID_LEVEL_FULL
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_VALID_LEVEL_FULL
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_VALID_LEVEL_FULL RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_VALID_LEVEL_INT
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  CS_INTERACTION_PVT.G_VALID_LEVEL_INT
   --   Return Type :  Number
   --
   --   End of Comments
   --
FUNCTION G_VALID_LEVEL_INT RETURN NUMBER;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_TRUE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_TRUE
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION G_TRUE RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  G_FALSE
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value of the Constant
   --                  FND_API.G_FALSE
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION G_FALSE RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  ENABLE_PLAN
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value 'APPLIED'.
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION ENABLE_PLAN RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  DISABLE_PLAN
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value 'DISABLED'.
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION DISABLE_PLAN RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  APPLY_PLAN
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value 'APPLIED'.
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION APPLY_PLAN RETURN VARCHAR2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  REMOVE_PLAN
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value 'REMOVED'.
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION REMOVE_PLAN RETURN VARCHAR2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  MERGE_PLAN
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value 'MERGED'.
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION MERGE_PLAN RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  TRANSFER_PLAN
   --   Type        :  Private Function
   --   Pre-Req     :  None
   --   Function    :  Returns the Value 'TRANSFERED'.
   --   Return Type :  Varchar2
   --
   --   End of Comments
   --
FUNCTION TRANSFER_PLAN RETURN Varchar2;

   --   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  GATHER_TABLE_STATS
   --   Type        :  Private Procedure
   --   Pre-Req     :  Table should exist under specified schema.
   --   Function    :  Invokes FND procedure FND_STATS.GATHER_TABLE_STATS which
   --                  estimates statistics for a given table. To be invoked
   --                  whenever generating stats. for the CBO during execution.
   --   Parameters  :
   --   IN
   --      p_ownname      IN   VARCHAR2 Optional   Default :=
   --                                   CSC_CORE_UTILS_PVT.G_APP_SHORTNAME
   --      p_tabname      IN   VARCHAR2
   --      p_percent      IN   NUMBER   Optional   Default := NULL
   --      p_degree       IN   NUMBER   Optional   Default := NULL
   --      p_partname     IN   VARCHAR2 Optional   Default := NULL
   --      p_backup_flag  IN   VARCHAR2 Optional   Default := 'NOBACKUP'
   --      p_cascade      IN   BOOLEAN  Optional   Default := TRUE
   --      p_tmode        IN   VARCHAR2 Optional   Default := 'NORMAL'
   --      p_granularity  IN   VARCHAR2 Optional   Default := 'DEFAULT'
   --
   --   End of Comments
   --
--Fix for Bug # 2443649
--Commented out this procedure as it is not used in any appl
/*
PROCEDURE GATHER_TABLE_STATS (
                P_OWNNAME            IN VARCHAR2  := CSC_CORE_UTILS_PVT.G_APP_SHORTNAME,
                P_TABNAME            IN VARCHAR2,
                P_PERCENT            IN NUMBER    := NULL,
                P_DEGREE             IN NUMBER    := NULL,
                P_PARTNAME           IN VARCHAR2  := NULL,
                P_BACKUP_FLAG        IN VARCHAR2  := 'NOBACKUP',
                P_CASCADE            IN BOOLEAN   := TRUE,
                P_TMODE              IN VARCHAR2  := 'NORMAL' ,
                P_GRANULARITY        IN VARCHAR2  := 'DEFAULT');

*/

PROCEDURE Handle_Exceptions(
                P_API_NAME        IN  VARCHAR2,
                P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER DEFAULT NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Dates (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_START_DATE      IN  DATE,
             P_END_DATE        IN  DATE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2);


PROCEDURE Validate_Not_Nulls (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_COLUMN_NAME     IN  VARCHAR2,
             P_COLUMN_VALUE    IN  VARCHAR2,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Not_Nulls (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_COLUMN_NAME     IN  VARCHAR2,
             P_COLUMN_VALUE    IN  NUMBER,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Not_Nulls (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_COLUMN_NAME     IN  VARCHAR2,
             P_COLUMN_VALUE    IN  DATE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2);

-- Start of Comments
--
-- Item level validation procedures for Seeded_flag added dated 15th June 2001 for
-- implementing Sequences.
--
-- End of Comments

PROCEDURE Validate_SEEDED_FLAG (
    P_API_NAME                   IN   VARCHAR2,
    P_SEEDED_FLAG                IN   VARCHAR2,
    X_Return_Status              OUT NOCOPY VARCHAR2
    );


/* This Procedure added for checking the Validity of Application Id for Enhancement 1784578 */

PROCEDURE Validate_Application_Id (
            P_Init_Msg_List              IN   VARCHAR2     :=CSC_CORE_UTILS_PVT.G_FALSE,
            P_Application_ID             IN   NUMBER DEFAULT NULL,
            X_Return_Status              OUT NOCOPY VARCHAR2,
            X_Msg_Count                  OUT NOCOPY NUMBER,
            X_Msg_Data                   OUT NOCOPY VARCHAR2,
            p_effective_date             IN   Date);

--   *******************************************************
   --    Start of Comments
   --   *******************************************************
   --   API Name    :  COMMIT_ROLLBACK
   --   Type        :  Private Procedure
   --   Pre-Req     :  None
   --   Function    :  Does a commit or a rollback on the server side.
   --
   --   PARAMETERS
   --   IN
   --      COM_ROLL     IN   VARCHAR2 Optional   Default := 'ROLL'
   --
   --   End of Comments
   --
PROCEDURE COMMIT_ROLLBACK(
	    COM_ROLL       IN   VARCHAR2 := 'ROLL') ;



 FUNCTION GET_COUNTER_NAME (p_COUNTER_ID NUMBER ) RETURN VARCHAR2;




-- ----------------------------------------------------------------------------
-- |----------------------< lookup_code_not_exists >---------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
--   A function for lookupcode validation. Used to validate a date tracked
--   lookupcode exists in fnd_lookups. Returns FND_API.G_RET_STS_SUCCESS
--   if the lookup code exists else returns FND_API.G_RET_STS_ERROR if the
--   lookup code doesnt exist or if not enabled or if it doesnt exist for
--   the specified period (p_effective_date).
--
--
-- In Arguments:
--   p_effective_date  IN DATE
--   p_lookup_type     IN VARCHAR2
--   p_lookup_code     IN VARCHAR2
--
--   Returns the status depending on the outcome
--   If p_currency_code is valid for the specified
--   (p_effective_date) period then returns
--   FND_API.G_RET_STS_SUCCESS else G_RET_STS_ERROR.

--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

FUNCTION lookup_code_not_exists
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return varchar2;



FUNCTION CSC_lookup_code_not_exists
  (p_effective_date             DATE
  ,p_lookup_type                VARCHAR2
  ,p_lookup_code                VARCHAR2
  ) return varchar2;

-- ----------------------------------------------------------------------------
-- |----------------------< currency_code_not_exists >---------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
--   A function for currency code validation. Used to validate a date tracked
--   currency code exists in fnd_currencies. Returns FND_API.G_RET_STS_SUCCESS
--   if the currency code exists else returns FND_API.G_RET_STS_ERROR if the
--   currency code doesnt exist or if not enabled or if it doesnt exist for
--   the specified period (p_effective_date).
--
--
-- In Arguments:
--   p_effective_date  IN DATE
--   p_lookup_type     IN VARCHAR2
--   p_lookup_code     IN VARCHAR2
--
--   Returns the status depending on the outcome.
--   If p_currency_code is enabled for the specified
--   (p_effective_date) period then returns
--   FND_API.G_RET_STS_SUCCESS else G_RET_STS_ERROR.
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

FUNCTION currency_code_not_exists
  (p_effective_date        in     date
  ,p_currency_code           in     varchar2
  ) return varchar2;

-- ---------------------------------------------------------------------------
-- -------------------------< validate_start_end_dt>---------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
--   Used for validating the start and end date. Assuming the start date will
--   never be NULL.If end_date is null then uses the fnd_api.g_miss_date to
--   validate the dates.

--   Writes the messages CS_ALL_START_DATE and CS_ALL_END_DATE. Returns
--   FND_API.G_RET_STS_SUCCESS if start_date < session_date and end_date < start_date
--   else returns FND_API.G_RET_STS_ERROR.

--
-- In Arguments:
--   p_api_name		IN	VARCHAR2
--   p_start_date		IN	DATE
--   p_end_date         IN	DATE
--   x_return_status    OUT   VARCHAR2
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

PROCEDURE Validate_Start_End_Dt
 ( p_api_name	  IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE DEFAULT NULL,
   x_return_status  OUT NOCOPY VARCHAR2
);

-- ---------------------------------------------------------------------------
-- -------------------------< Add_Invalid_Argument_Msg>------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
-- Writes an Invalid Argument message using the api_name, parameter name and
-- the parameter value.

--
-- In Arguments:
--   p_token_an		IN	VARCHAR2   -- api_name
--   p_token_v		IN	VARCHAR2   -- parameter value
--   p_token_p		IN	VARCHAR2   -- parameter name
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

PROCEDURE Add_Invalid_Argument_Msg
( p_api_name		VARCHAR2,
  p_argument		VARCHAR2,
  p_argument_value	VARCHAR2
);

-- ---------------------------------------------------------------------------
-- -------------------------< Record_Is_Locked_Msg>------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
-- Writes an Record Locked message using the api_name.

--
-- In Arguments:
--   p_token_an		IN	VARCHAR2   -- api_name
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

PROCEDURE Record_Is_Locked_Msg
( p_api_name	VARCHAR2
);

-- ---------------------------------------------------------------------------
-- -------------------------< Cannot_Update_Param_Msg>------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description:
-- Writes a cannot update message.

--
-- In Arguments:
--   p_token_an		IN	VARCHAR2   -- api_name
--   p_token_cn		IN	VARCHAR2   -- column name
--   p_token_v		IN	VARCHAR2   -- column value
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

PROCEDURE Cannot_Update_Param_Msg
( p_api_name	VARCHAR2,
  p_argument	VARCHAR2,
  p_argument_value	VARCHAR2
);

-- ---------------------------------------------------------------------------
-- -------------------------< Add_Null_Parameter_Msg>--------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--
-- Description: This procedure is called by business processes which have
--              identified a NULL argument error which needs to be NOT null.
--              If the argument is null then need to error.
--              Varchar2 format.

-- Description:
-- Writes an cannot update the column message.

--
-- In Arguments:
--   p_token_an		IN	VARCHAR2   -- api_name
--   p_token_cn		IN	VARCHAR2   -- column name
--   p_token_v		IN	VARCHAR2   -- column value
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}


PROCEDURE Add_Null_Parameter_Msg
( p_api_name	VARCHAR2,
  p_argument	VARCHAR2
);

-- ---------------------------------------------------------------------------
-- -------------------------< Add_Duplicate_Value_Msg>------------------------
-- ----------------------------------------------------------------------------
-- Description:
--  This procedure adds Invalid arguments message to the
--  messages que
--
--
--  In Arguments:
--   p_api_name
--   p_argument
--   p_argument_value
--
--
--
-- For CSC Development.

PROCEDURE Add_Duplicate_Value_Msg
( p_api_name		VARCHAR2,
  p_argument		VARCHAR2,
  p_argument_value	VARCHAR2
);

-- ---------------------------------------------------------------------------
-- -------------------------< Mandatory_arg_Error>--------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description: This procedure is called by business processes which have
--              identified a mandatory argument which needs to be NOT null.
--              If the argument is null then need to error.
--              Varchar2 format.

--
-- In Arguments:
--   p_api_name			IN	VARCHAR2   -- api_name
--   p_argument			IN	VARCHAR2   -- column name
--   p_argument_value		IN	VARCHAR2   -- column value
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}

Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      varchar2 );
--

-- ---------------------------------------------------------------------------
-- -------------------------< Mandatory_arg_Error>--------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description: This procedure is called by business processes which have
--              identified a mandatory argument which needs to be NOT null.
--              If the argument is null then need to error.
--              Date format.
--		Overloaded procedure which converts argument into a varchar2.

--
-- In Arguments:
--   p_api_name			IN	VARCHAR2   -- api_name
--   p_argument			IN	VARCHAR2   -- column name
--   p_argument_value		IN	date   -- column value
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}
--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      date);
--
-- ---------------------------------------------------------------------------
-- -------------------------< Mandatory_arg_Error>--------------------------
-- ----------------------------------------------------------------------------
-- {Start Of Comments}
--

-- Description: This procedure is called by business processes which have
--              identified a mandatory argument which needs to be NOT null.
--              If the argument is null then need to error.
--              Number format.
-- 		Overloaded procedure which converts argument into a varchar2.
--
-- In Arguments:
--   p_api_name			IN	VARCHAR2   -- api_name
--   p_argument			IN	VARCHAR2   -- column name
--   p_argument_value		IN	number   -- column value
--
--
-- Access Status:
--   Internal Development Use Only.

--
-- {End Of Comments}
--
--

--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      number );


-- ---------------------------------------------------------------------------
-- -------------------------< Validate_Sql_Stmnt>--------------------------
-- ----------------------------------------------------------------------------
-- Description:

PROCEDURE Validate_Sql_Stmnt
( p_sql_stmnt	IN	VARCHAR2,
  x_return_status	OUT	NOCOPY VARCHAR2 );


-- ---------------------------------------------------------------------------
-- -------------------------< Build_Sql_Stmnt>--------------------------
-- ----------------------------------------------------------------------------
-- Description:

PROCEDURE Build_Sql_Stmnt
( p_select_clause IN	VARCHAR2,
  p_from_clause	IN	VARCHAR2,
  p_where_clause	IN	VARCHAR2,
  p_other_clause 	IN	VARCHAR2,
  x_sql_Stmnt	OUT	NOCOPY VARCHAR2,
  x_return_status	OUT	NOCOPY VARCHAR2 );

FUNCTION Get_G_Miss_Char(p_value IN Varchar2, p_old_value IN Varchar2)
RETURN VARCHAR2;

FUNCTION Get_G_Miss_Num(p_value IN Number, p_old_value IN Number)
RETURN NUMBER;

FUNCTION Get_G_Miss_Date(p_value IN Date, p_old_value IN Date)
RETURN Date;


END CSC_CORE_UTILS_PVT;

 

/
