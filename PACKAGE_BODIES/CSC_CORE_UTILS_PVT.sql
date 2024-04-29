--------------------------------------------------------
--  DDL for Package Body CSC_CORE_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_CORE_UTILS_PVT" as
/* $Header: cscvcorb.pls 115.18 2002/12/04 19:13:32 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_CORE_UTILS_PVT
-- Purpose          : This package contains all the common procedure, functions and global
--                    variables that will be used by the CUSTOMER CARE-MODULE.
--
-- History
-- MM-DD-YYYY    NAME          MODIFICATION
-- 10-08-1999    dejoseph      Created.
-- 12-08-1999    dejoseph      'Arcs'ed in for first code freeze.
-- 12-21-1999    dejoseph      'Arcs'ed in for second code freeze.
-- 01-03-2000    dejoseph      'Arcs'ed in for third code freeze. (10-JAN-2000)
-- 01-31-2000    dejoseph      'Arcs'ed in for fourth code freeze. (07-FEB-2000)
-- 02-04-2000    agaddam       Added a new function get_counter_name to be used in a view.
-- 02-13-2000    dejoseph      'Arcs'ed on for fifth code freeze. (21-FEB-2000)
-- 02-28-2000    dejoseph      'Arcs'ed on for sixth code freeze. (06-MAR-2000)
-- 05-04-2000    dejoseph      Included procedure to gather CBO statistics on a given
--                             table.
-- 02-22-2001    dejoseph      Added two more plan status functions, MERGE_PLAN and
--                             TRANSFER_PLAN for the purpose of Party Merge.
-- 12-03-2002    jamose        Added function for Fnd_Api_G_Miss* Changes
-- End of Comments
--

FUNCTION G_CREATE RETURN VARCHAR2 IS
BEGIN
   RETURN L_CREATE;
END;

FUNCTION G_UPDATE RETURN VARCHAR2 IS
BEGIN
   RETURN L_UPDATE;
END;


FUNCTION G_MISS_NUM RETURN NUMBER IS
BEGIN
   RETURN FND_API.G_MISS_NUM ;
END G_MISS_NUM ;


FUNCTION G_MISS_CHAR RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_MISS_CHAR ;
END G_MISS_CHAR ;


FUNCTION G_MISS_DATE RETURN DATE IS
BEGIN
   RETURN FND_API.G_MISS_DATE ;
END G_MISS_DATE ;


FUNCTION G_RET_STS_SUCCESS RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_RET_STS_SUCCESS ;
END G_RET_STS_SUCCESS ;


FUNCTION G_RET_STS_ERROR RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_RET_STS_ERROR ;
END G_RET_STS_ERROR ;


FUNCTION G_RET_STS_UNEXP_ERROR RETURN VARCHAR2 IS
BEGIN
   RETURN FND_API.G_RET_STS_UNEXP_ERROR ;
END G_RET_STS_UNEXP_ERROR ;


FUNCTION G_VALID_LEVEL_NONE RETURN NUMBER IS
BEGIN
   RETURN FND_API.G_VALID_LEVEL_NONE ;
END;


FUNCTION G_VALID_LEVEL_FULL RETURN NUMBER IS
BEGIN
   RETURN FND_API.G_VALID_LEVEL_FULL ;
END;


FUNCTION G_VALID_LEVEL_INT RETURN NUMBER IS
BEGIN
   RETURN CS_INTERACTION_PVT.G_VALID_LEVEL_INT ;
END;


FUNCTION G_TRUE RETURN VARCHAR2 IS
BEGIN
   return FND_API.G_TRUE ;
END;


FUNCTION G_FALSE RETURN VARCHAR2 IS
BEGIN
   return FND_API.G_FALSE ;
END;

FUNCTION ENABLE_PLAN RETURN VARCHAR2 IS
BEGIN
   return 'APPLIED';
END;

FUNCTION DISABLE_PLAN RETURN VARCHAR2 IS
BEGIN
   return 'DISABLED';
END;

FUNCTION APPLY_PLAN RETURN VARCHAR2 IS
BEGIN
   return 'APPLIED';
END;

FUNCTION REMOVE_PLAN RETURN VARCHAR2 IS
BEGIN
   return 'REMOVED';
END;

FUNCTION MERGE_PLAN RETURN VARCHAR2 IS
BEGIN
   return 'MERGED';
END;

FUNCTION TRANSFER_PLAN RETURN VARCHAR2 IS
BEGIN
   return 'TRANSFERED';
END;

-- Fix for Bug#2443649
-- commenting out the procedure as this is not used in any appl.
-- parmateres for fnd_stats.gather_tabel_stats have been changed
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
                P_GRANULARITY        IN VARCHAR2  := 'DEFAULT')
IS
BEGIN
   FND_STATS.GATHER_TABLE_STATS (
                OWNNAME            => p_ownname,
                TABNAME            => p_tabname,
                PERCENT            => p_percent,
                DEGREE             => p_degree,
                PARTNAME           => p_partname,
                BACKUP_FLAG        => p_backup_flag,
                CASCADE            => p_cascade,
                TMODE              => p_tmode ,
                GRANULARITY        => p_granularity );

EXCEPTION
  WHEN OTHERS THEN
	NULL;

END GATHER_TABLE_STATS;
*/

PROCEDURE Handle_Exceptions(
			 P_API_NAME        IN  VARCHAR2,
			 P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER   DEFAULT NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY	 NUMBER,
                X_MSG_DATA        OUT NOCOPY VARCHAR2,
                X_RETURN_STATUS   OUT NOCOPY VARCHAR2)

IS
   l_api_name    VARCHAR2(30);
BEGIN
    l_api_name := UPPER(p_api_name);

    DBMS_TRANSACTION.ROLLBACK_SAVEPOINT(l_api_name || p_package_type);
    IF p_exception_level = FND_MSG_PUB.G_MSG_LVL_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
    THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    ELSIF p_exception_level = CSC_CORE_UTILS_PVT.G_MSG_LVL_OTHERS
    THEN
	  x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	  -- Insert the 'sqlerrm' into the message stack.
	  FND_MSG_PUB.BUILD_EXC_MSG (
		p_pkg_name         => p_pkg_name,
		p_procedure_name   => p_api_name );

        FND_MSG_PUB.Count_And_Get(
            p_encoded =>  FND_API.G_FALSE,
            p_count   =>  x_msg_count,
            p_data    =>  x_msg_data);
    END IF;
END Handle_exceptions;

PROCEDURE Validate_Dates (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_START_DATE      IN  DATE,
             P_END_DATE        IN  DATE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2)

IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF ( p_start_date > p_end_date ) then
            fnd_message.set_name (G_APP_SHORTNAME, 'CS_ALL_START_DATE_AFTER_END');
            --fnd_msg_pub.add;
           x_return_status := FND_API.G_RET_STS_ERROR;
           IF (p_end_date = G_MISS_DATE) THEN
                 x_return_status := FND_API.G_RET_STS_SUCCESS;
           END IF;

      END IF;

/*
      if ( P_Validation_Mode = CSC_CORE_UTILS_PVT.G_UPDATE ) then
         if ( p_start_date < sysdate ) then
            FND_MESSAGE.SET_NAME (G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'VALIDATE_DATES');
            FND_MESSAGE.SET_TOKEN('VALUE', p_start_date); -- parameter here is start_date.
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_START_DATE');
            --FND_MSG_PUB.Add;
         end if;
         if ( p_end_date < sysdate ) then
            FND_MESSAGE.SET_NAME (G_APP_SHORTNAME, 'CS_API_ALL_INVALID_ARGUMENT');
            FND_MESSAGE.SET_TOKEN('API_NAME', 'VALIDATE_DATES');
            FND_MESSAGE.SET_TOKEN('VALUE', p_end_date); -- parameter here is start_date.
            FND_MESSAGE.SET_TOKEN('PARAMETER', 'P_END_DATE');
            --FND_MSG_PUB.Add;
         end if;
      end if;
	 */

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
         p_encoded        =>  FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

END  Validate_dates;


PROCEDURE Validate_Not_Nulls (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_COLUMN_NAME     IN  VARCHAR2,
             P_COLUMN_VALUE    IN  VARCHAR2,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2)
IS
   l_api_name   varchar2(30)  := 'VALIDATE_NOT_NULLS';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      if (p_column_value is NULL or p_column_value = FND_API.G_MISS_CHAR ) then
         fnd_message.set_name (G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', p_column_name);
         --fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
         p_encoded =>  FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

END Validate_Not_Nulls;

PROCEDURE Validate_Not_Nulls (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_COLUMN_NAME     IN  VARCHAR2,
             P_COLUMN_VALUE    IN  NUMBER,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2)
IS
   l_api_name   varchar2(30)  := 'VALIDATE_NOT_NULLS';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      if (p_column_value is NULL or p_column_value = FND_API.G_MISS_NUM ) then
         fnd_message.set_name (G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', p_column_name);
         --fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get(
         p_encoded        =>  FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

END Validate_Not_Nulls;


PROCEDURE Validate_Not_Nulls (
             p_init_msg_list   IN  VARCHAR2  := FND_API.G_FALSE,
             p_validation_mode IN  VARCHAR2,
             P_COLUMN_NAME     IN  VARCHAR2,
             P_COLUMN_VALUE    IN  DATE,
             x_return_status   OUT NOCOPY VARCHAR2,
             x_msg_count       OUT NOCOPY NUMBER,
             x_msg_data        OUT NOCOPY VARCHAR2)
IS
   l_api_name   varchar2(30)  := 'VALIDATE_NOT_NULLS';
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      if (p_column_value is NULL or p_column_value = FND_API.G_MISS_DATE ) then
         fnd_message.set_name (G_APP_SHORTNAME, 'CS_API_ALL_NULL_PARAMETER');
         fnd_message.set_token ('API_NAME', G_PKG_NAME||'.'||l_api_name);
         fnd_message.set_token('NULL_PARAM', p_column_name);
         --fnd_msg_pub.add;
         x_return_status := FND_API.G_RET_STS_ERROR;
      end if;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
         p_encoded =>  FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data);

END Validate_Not_Nulls;

PROCEDURE Validate_Seeded_Flag
( p_api_name        IN  VARCHAR2,
  p_seeded_flag     IN  VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2
) IS
  --
 BEGIN
  --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- check if the seeded flag is passed in and is not
  -- null, if passed in check if the lookup code
  -- exists in fnd lookups for this date, if not
  -- its an invalid argument.
  IF (( p_seeded_flag <> CSC_CORE_UTILS_PVT.G_MISS_CHAR ) AND
        ( p_seeded_flag IS NOT NULL )) THEN
    IF CSC_CORE_UTILS_PVT.lookup_code_not_exists(
        p_effective_date  => trunc(sysdate),

        p_lookup_type     => 'YES_NO',
        p_lookup_code     => p_seeded_flag ) <> FND_API.G_RET_STS_SUCCESS

 THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        CSC_CORE_UTILS_PVT.Add_Invalid_Argument_Msg(p_api_name => p_api_name,
                                    p_argument_value  => p_seeded_flag,
                                    p_argument  => 'p_Seeded_flag');
    END IF;
  END IF;
END Validate_Seeded_Flag;


/* Added this Procedure for validation of Application_id for Enhancement 1784578*/

PROCEDURE Validate_APPLICATION_ID (
   P_Init_Msg_List              IN   VARCHAR2     :=CSC_CORE_UTILS_PVT.G_FALSE,
   P_Application_ID             IN   NUMBER DEFAULT NULL,
   X_Return_Status              OUT NOCOPY VARCHAR2,
   X_Msg_Count                  OUT NOCOPY NUMBER,
   X_Msg_Data                   OUT NOCOPY VARCHAR2,
   p_effective_date             IN   Date
   )
IS
   l_temp_id    number:=0;

BEGIN
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      FND_MSG_PUB.initialize;
   END IF;

 -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

IF (( p_application_id <> CSC_CORE_UTILS_PVT.G_MISS_NUM ) AND
        ( p_application_id IS NOT NULL )) THEN

        select 1 into l_temp_id from fnd_application
	where application_id=p_application_id;
--	and trunc(p_effective_date) between trunc(nvl(start_date_active,p_effective_date))
--	and trunc(nvl(end_date_active,p_effective_date));
End If;


Exception

   When no_data_found then
         fnd_message.set_name ('FND', 'CONC-INVALID APPLICATION ID');
         fnd_message.set_token('ID', p_application_id);
         x_return_status := FND_API.G_RET_STS_ERROR;

  When others Then
         fnd_message.set_name ('FND', 'CONC-INVALID APPLICATION ID');
         fnd_message.set_token('ID', p_application_id);
         x_return_status := FND_API.G_RET_STS_ERROR;

END Validate_APPLICATION_ID;



PROCEDURE COMMIT_ROLLBACK(
	    COM_ROLL       IN   VARCHAR2 := 'ROLL')
IS
BEGIN
   if ( COM_ROLL = 'COMMIT' ) then
	 commit;
   else
	 rollback;
   end if;
END;

FUNCTION GET_COUNTER_NAME( p_COUNTER_ID NUMBER )
RETURN VARCHAR2
IS
 l_counter_name cs_counters.name%type;
 Cursor C1 is
  select name
  from cs_counters
  where counter_id = p_counter_id;
BEGIN
 OPEN C1;
 FETCH C1 into l_counter_name;
 CLOSE C1;
 return( l_counter_name );
END GET_COUNTER_NAME;



-- ----------------------------------------------------------------------------
-- |----------------------< currency_code_not_exists >---------------------------
-- ----------------------------------------------------------------------------
-- Description:
--  Function used to validate the currency code
--  for the specified period.
--
--   Returns the status depending on the outcome
--   If p_currency_code is valid for the specified
--   (p_effective_date) period then returns
--   FND_API.G_RET_STS_SUCCESS else G_RET_STS_ERROR.
--
--  The calling program should write the error message
--  depending on the return status from the function
--
--  For CSC Development.

FUNCTION currency_code_not_exists
  (p_effective_date	in     date,
   p_currency_code	in     varchar2
  ) return varchar2 is
  --
  -- Declare Local Variables
  --
  l_dummy          varchar2(1);
  l_return_status  varchar2(30);
  --
  -- Declare Local cursors
  --
  cursor csr_currency_look is
    select null
    from fnd_currencies
    where currency_code = p_currency_code
    and  trunc(p_effective_date) between trunc(nvl(start_date_active, p_effective_date))
	   and trunc(nvl(end_date_active, p_effective_date));
BEGIN
  -- Initialize the return status to success.
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   open csr_currency_look;
   fetch csr_currency_look into l_dummy;
    if csr_currency_look%notfound then
     close csr_currency_look;
   	 l_return_status := FND_API.G_RET_STS_ERROR;
       --** invalid arg;
    end if;
    if csr_currency_look%ISOPEN then
   	  close csr_currency_look;
    end if;
   return (l_return_status);
END currency_code_not_exists;


-- ----------------------------------------------------------------------------
-- |----------------------< lookup_code_not_exists >---------------------------
-- ----------------------------------------------------------------------------
-- Description:
--  Function used to validate the lookup code using
--  the fnd_lookups table returns TRUE if the lookup code
--  exists else returns FALSE.
--
--  Uses p_effective_Date to date track the records.
--
--  The calling program should write the error message
--  depending on the return status from the function
--
--   Returns the status depending on the outcome.
--   If p_currency_code is enabled for the specified
--   (p_effective_date) period then returns
--   FND_API.G_RET_STS_SUCCESS else G_RET_STS_ERROR.
--
--
-- For CSC Development.

FUNCTION lookup_code_not_exists
  (p_effective_date        in     date
  ,p_lookup_type           in     varchar2
  ,p_lookup_code           in     varchar2
  ) return varchar2 is
  --
  -- Declare Local Variables
  --
  l_dummy          varchar2(1);
  l_return_status  varchar2(30);
  --
  -- Declare Local cursors
  --
  cursor csr_lookup_code is
   select null
   from fnd_lookups
   where lookup_code  = p_lookup_code
   and lookup_type  = p_lookup_type
   and enabled_flag = 'Y'
   and trunc(p_effective_date) between
               trunc(nvl(start_date_active, p_effective_date))
           and trunc(nvl(end_date_active, p_effective_date));
BEGIN
  -- Initialize the return status to success.
   l_return_status := FND_API.G_RET_STS_SUCCESS;
   open csr_lookup_code;
   fetch csr_lookup_code into l_dummy;
    if csr_lookup_code%notfound then
       close csr_lookup_code;
 	 l_return_status := FND_API.G_RET_STS_ERROR;
    end if;
   if csr_lookup_code%ISOPEN then
     close csr_lookup_code;
   end if;
   return ( l_return_status );
END lookup_code_not_exists;


FUNCTION csc_lookup_code_not_exists
  (p_effective_date             DATE
  ,p_lookup_type                VARCHAR2
  ,p_lookup_code                VARCHAR2
  ) return varchar2 IS

  --
  -- Declare Local Variables
  --
  l_dummy          varchar2(1);
  l_return_status  varchar2(30);
  --
  -- Declare Local cursors
  --
  cursor csr_lookup_code is
   select null
   from CSC_LOOKUPS
   where lookup_code  = p_lookup_code
   and lookup_type  = p_lookup_type
   and enabled_flag = 'Y'
   and trunc(p_effective_date) between
               trunc(nvl(start_date_active, p_effective_date))
           and trunc(nvl(end_date_active, p_effective_date));
BEGIN

  -- Initialize the return status to success.
   l_return_status := FND_API.G_RET_STS_SUCCESS;

   open csr_lookup_code;
   fetch csr_lookup_code into l_dummy;
    if csr_lookup_code%notfound then
       close csr_lookup_code;
 	 l_return_status := FND_API.G_RET_STS_ERROR;
    end if;
   if csr_lookup_code%ISOPEN then
     close csr_lookup_code;
   end if;

   return ( l_return_status );

END csc_lookup_code_not_exists;

-- ---------------------------------------------------------------------------
-- -------------------------< Add_Invalid_Argument_Msg>------------------------
-- ----------------------------------------------------------------------------
-- Description:
--  This procedure adds Invalid arguments message to the
--  messages que
--
--
--
-- For CSC Development.

PROCEDURE Add_Invalid_Argument_Msg
( p_api_name		VARCHAR2,
  p_argument		VARCHAR2,
  p_argument_value	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_INVALID_ARGUMENT');
    FND_MESSAGE.Set_Token('API_NAME', p_api_name);
    FND_MESSAGE.Set_Token('VALUE', p_argument_value);
    FND_MESSAGE.Set_Token('PARAMETER', p_argument);
  END IF;
END Add_Invalid_Argument_Msg;


-- ---------------------------------------------------------------------------
-- -------------------------< validate_start_end_dt>---------------------------
-- ----------------------------------------------------------------------------
-- Description:
--  Procedure  used to validate the start and end dates.
--  Write a CS_ALL_START_DATE message if the start date
--  is less than the sysdate and CS_ALL_END_DATE message
--  if end date is less then the start date.
--
--
-- For CSC Development.

PROCEDURE Validate_Start_End_Dt
 ( p_api_name	  IN  VARCHAR2,
   p_start_date     IN  DATE,
   p_end_date       IN  DATE DEFAULT NULL,
   x_return_status  OUT NOCOPY VARCHAR2 )
IS
 --
 x_msg_count number;
 x_msg_data varchar2(500);

 BEGIN
 --
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 --

--** need to check out


    Validate_Dates (
             p_init_msg_list   =>  FND_API.G_FALSE,
             p_validation_mode =>  NULL,
             P_START_DATE      => p_start_date,
             P_END_DATE        => p_end_date,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data );

/*
  IF ( p_start_date IS NOT NULL ) THEN
     IF p_start_date < sysdate THEN
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('CS', 'CS_ALL_START_DATE');
	   FND_MESSAGE.Set_Token('START_DATE' ,p_start_date);
	   FND_MESSAGE.Set_Token('END_DATE' ,p_end_date);
	 END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;

     END IF;
  --
      IF( p_end_date < p_start_date ) THEN
  	  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	   FND_MESSAGE.Set_Name('CS', 'CS_ALL_END_DATE');
	   FND_MESSAGE.Set_Token('START_DATE' ,p_start_date);
	   FND_MESSAGE.Set_Token('END_DATE' ,p_end_date);
	  END IF;
         x_return_status := FND_API.G_RET_STS_ERROR;
     END IF;
  END IF;
*/
END;

-- ---------------------------------------------------------------------------
-- -------------------------< Record_Is_Locked_Msg>------------------------
-- ----------------------------------------------------------------------------

-- Description:
--  This procedure adds Record Locked message to the
--  messages que
--
--
-- For CSC Development.


PROCEDURE Record_Is_Locked_Msg
( p_api_name	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_CANT_LOCK_RECORD');
    FND_MESSAGE.Set_Token('API_NAME', p_api_name);
  END IF;
END Record_IS_Locked_Msg;

-- ---------------------------------------------------------------------------
-- -------------------------< Cannot_Update_Param_Msg>------------------------
-- ----------------------------------------------------------------------------
-- Description:
-- Adds a cannot update parameter messages.
--
--
--
--
-- For CSC Development.

PROCEDURE Cannot_Update_Param_Msg
( p_api_name	VARCHAR2,
  p_argument	VARCHAR2,
  p_argument_value	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
	--** check the message name
    FND_MESSAGE.Set_Name('CS', 'CS_API_CHG_CANT_UPD_PARAM');
    FND_MESSAGE.Set_Token('API_NAME', p_api_name);
    FND_MESSAGE.Set_Token('COLUMN_NAME', p_argument);
    FND_MESSAGE.Set_Token('VALUE', p_argument_value);
  END IF;
END;

-- ---------------------------------------------------------------------------
-- -------------------------< Add_Null_Parameter_Msg>--------------------------
-- ----------------------------------------------------------------------------

-- Description:
-- Writes a Null Parameter Message to the message que.
--
--
--
-- For CSC Development.

PROCEDURE Add_Null_Parameter_Msg
( p_api_name	VARCHAR2,
  p_argument	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_NULL_PARAMETER');
    FND_MESSAGE.Set_Token('API_NAME', p_api_name);
    FND_MESSAGE.Set_Token('NULL_PARAM', p_argument);
  END IF;
END Add_Null_Parameter_Msg;

-- ---------------------------------------------------------------------------
-- -------------------------< Add_Duplicate_Value_Msg>------------------------
-- ----------------------------------------------------------------------------
-- Description:
--  This procedure adds Invalid arguments message to the
--  messages que
--
--
--
--
-- For CSC Development.

PROCEDURE Add_Duplicate_Value_Msg
( p_api_name		VARCHAR2,
  p_argument		VARCHAR2,
  p_argument_value	VARCHAR2
)
IS
BEGIN
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_DUPLICATE_VALUE');
    FND_MESSAGE.Set_Token('API_NAME', p_api_name);
    FND_MESSAGE.Set_Token('DUPLICATE_VAL_PARAM', p_argument_value);
  END IF;
END Add_Duplicate_Value_Msg;

-- ---------------------------------------------------------------------------
-- -------------------------< Mandatory_arg_Error>--------------------------
-- ----------------------------------------------------------------------------
-- Description: This procedure is called by business processes which have
--              identified a mandatory argument which needs to be NOT null.
--              If the argument is null then need to error.
--              Varchar2 format.

Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      varchar2) is
--
Begin

 --
  IF  FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR ) THEN
    FND_MESSAGE.Set_Name('CS', 'CS_API_ALL_MISSING_PARAM');
    FND_MESSAGE.Set_Token('API_NAME', p_api_name);
    FND_MESSAGE.Set_Token('MISSING_PARAM', p_argument);
  End If;
  --

End mandatory_arg_error;

-- ---------------------------------------------------------------------------
-- -------------------------< Mandatory_arg_Error>--------------------------
-- ----------------------------------------------------------------------------
-- Description: Overloaded procedure which converts argument into a varchar2.
--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      date) is
--
Begin
 --

  mandatory_arg_error(
 	  p_api_name => p_api_name,
        p_argument => p_argument,
        p_argument_value => to_char(p_argument_value,'DD-MON-YYYY'));

 --
End mandatory_arg_error;

-- ---------------------------------------------------------------------------
-- -------------------------< Mandatory_arg_Error>--------------------------
-- ----------------------------------------------------------------------------
-- Description: Overloaded procedure which converts argument into a varchar2.

--
Procedure mandatory_arg_error
            (p_api_name         in      varchar2,
             p_argument         in      varchar2,
             p_argument_value   in      number) is
--
Begin
 --
  mandatory_arg_error(
	  p_api_name => p_api_name,
        p_argument => p_argument,
        p_argument_value => to_char(p_argument_value));
 --
End mandatory_arg_error;

-- ---------------------------------------------------------------------------
-- -------------------------< Validate_Sql_Stmnt>--------------------------
-- ----------------------------------------------------------------------------
-- Description:

PROCEDURE Validate_Sql_Stmnt
( p_sql_stmnt	IN	VARCHAR2,
  x_return_status	OUT	NOCOPY VARCHAR2 )
IS
l_sql_cur_hdl  INT;
BEGIN

  -- initialize the return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  -- if the sql_statement is passed in and if its NOT NULL then
  -- validate the sql_statement by parsing it using the dbms_sql
  -- package.
  IF (( p_sql_stmnt IS NOT NULL ) and
      ( p_sql_stmnt <> FND_API.G_MISS_CHAR )) THEN
    l_sql_cur_hdl := DBMS_SQL.OPEN_CURSOR;
    DBMS_SQL.PARSE( l_sql_cur_hdl, p_sql_stmnt, DBMS_SQL.NATIVE );
    DBMS_SQL.CLOSE_CURSOR( l_sql_cur_hdl );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
     IF DBMS_SQL.IS_OPEN( l_Sql_cur_hdl ) THEN
	 DBMS_SQL.CLOSE_CURSOR(l_Sql_cur_hdl );
     END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Validate_Sql_Stmnt;

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
  x_return_status	OUT NOCOPY	VARCHAR2 )
IS
 l_sql_stmnt VARCHAR2(2000);
BEGIN

   -- initialize the return status
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- check if the select_clause and the from_Clause
   -- is NULL or missing, if so we cannot form an
   -- sql_statement.

   IF ((( p_Select_Clause IS NULL ) and
       ( p_Select_Clause = FND_API.G_MISS_CHAR ))
      and (( p_from_Clause IS NULL ) and
	 ( p_from_Clause = FND_API.G_MISS_CHAR )))
   THEN
      -- invalid arguments exception
      x_return_status := FND_API.G_RET_STS_ERROR;
   ELSE
     -- if present concatenate both the clauses.
     l_sql_stmnt := 'SELECT '||p_select_clause||' FROM '||p_from_clause;
   END IF;

   -- if where_clause is passsed in contenate to the select and from clauses
   IF (( p_where_clause IS NOT NULL )
	and ( p_where_clause <> FND_API.G_MISS_CHAR )) THEN
     l_sql_stmnt := l_sql_stmnt||' WHERE '||p_where_clause;
   END IF;

   -- if other_clause is not null then concatenate
   IF (( p_other_clause IS NOT NULL )
	and ( p_other_clause <> FND_API.G_MISS_CHAR )) THEN
     l_sql_stmnt := l_sql_stmnt||' '||p_other_clause;
   END IF;
   x_sql_stmnt := l_sql_stmnt;
EXCEPTION
 WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END Build_Sql_Stmnt;


FUNCTION Get_G_Miss_Char(p_value IN Varchar2, p_old_value IN Varchar2)
RETURN VARCHAR2 IS
BEGIN
   IF p_value = G_MISS_CHAR THEN
      RETURN NULL;
   ELSIF p_value IS NULL THEN
      RETURN p_old_value;
   ELSE RETURN p_value;
   END IF;
END;

FUNCTION Get_G_Miss_Num(p_value IN NUMBER, p_old_value IN NUMBER)
RETURN NUMBER IS
BEGIN
   IF p_value = G_MISS_NUM THEN
      RETURN NULL;
   ELSIF p_value IS NULL THEN
      RETURN p_old_value;
   ELSE
      RETURN p_value;
   END IF;
END;

FUNCTION Get_G_Miss_Date(p_value IN DATE, p_old_value IN DATE)
RETURN DATE IS
BEGIN
   IF p_value = G_MISS_DATE THEN
      RETURN NULL;
   ELSIF p_value IS NULL THEN
      RETURN p_old_value;
   ELSE
      RETURN p_value;
   END IF;
END;


END CSC_CORE_UTILS_PVT;

/
