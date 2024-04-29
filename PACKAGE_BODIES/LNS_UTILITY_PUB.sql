--------------------------------------------------------
--  DDL for Package Body LNS_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."LNS_UTILITY_PUB" AS
/*$Header: LNS_UTIL_PUBP_B.pls 120.11 2006/02/20 15:36:52 karamach noship $ */

  G_PKG_NAME CONSTANT VARCHAR2(30) := 'LNS_UTILITIES';
  G_FILE_NAME CONSTANT VARCHAR2(30) := 'LNS_UTIL_PUBP_B.pls';

 --------------------------------------------
 -- internal package routines
 --------------------------------------------

procedure logMessage(log_level in number
                    ,module    in varchar2
                    ,message   in varchar2)
is

begin

    IF log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
      FND_LOG.STRING(log_level, module, message);
    END IF;

end;

FUNCTION created_by RETURN NUMBER IS
BEGIN

    RETURN NVL(FND_GLOBAL.user_id,-1);

END created_by;

FUNCTION creation_date RETURN DATE IS
BEGIN

    RETURN SYSDATE;

END creation_date;

FUNCTION last_updated_by RETURN NUMBER IS
BEGIN

    RETURN NVL(FND_GLOBAL.user_id,-1);

END last_updated_by;

FUNCTION last_update_date RETURN DATE IS
BEGIN

    RETURN SYSDATE;

END last_update_date;

FUNCTION last_update_login RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.conc_login_id = -1 OR
       FND_GLOBAL.conc_login_id IS NULL
    THEN
        RETURN FND_GLOBAL.login_id;
    ELSE
        RETURN FND_GLOBAL.conc_login_id;
    END IF;

END last_update_login;

FUNCTION request_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.conc_request_id = -1 OR
       FND_GLOBAL.conc_request_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.conc_request_id;
    END IF;

END request_id;

FUNCTION program_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.conc_program_id = -1 OR
       FND_GLOBAL.conc_program_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.conc_program_id;
    END IF;

END program_id;

FUNCTION program_application_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.prog_appl_id = -1 OR
       FND_GLOBAL.prog_appl_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.prog_appl_id;
    END IF;

END program_application_id;

FUNCTION application_id RETURN NUMBER IS
BEGIN

    IF FND_GLOBAL.resp_appl_id = -1 OR
       FND_GLOBAL.resp_appl_id IS NULL
    THEN
        RETURN NULL;
    ELSE
        RETURN FND_GLOBAL.resp_appl_id;
    END IF;

END application_id;

FUNCTION program_update_date RETURN DATE IS
BEGIN

    IF program_id IS NULL THEN
        RETURN NULL;
    ELSE
        RETURN SYSDATE;
    END IF;

END program_update_date;

FUNCTION user_id RETURN NUMBER IS
BEGIN

    RETURN NVL(FND_GLOBAL.user_id,-1);

END user_id;

PROCEDURE Validate_any_id(p_api_version   IN  NUMBER := 1.0,
                          p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                          x_msg_count     OUT NOCOPY NUMBER,
                          x_msg_data      OUT NOCOPY VARCHAR2,
                          x_return_status OUT NOCOPY VARCHAR2,
                          p_col_id        IN NUMBER,
                          p_col_name      IN VARCHAR2,
                          p_table_name    IN VARCHAR2)
IS

TYPE refCur IS REF CURSOR;
valid_id  refCur;

    l_return_status VARCHAR2(1);
    count_id        VARCHAR2(1);
    l_api_version   NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_api_name      VARCHAR2(20) := 'VALIDATE_ANY_ID';
    vPlsql          VARCHAR2(2000);
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_any_id_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- API body
       vPlsql :=
             ' Select ''X'' ' ||
             ' From ' || p_table_name || ' ' ||
             ' Where exists ' ||
             '     (Select ' || p_col_name ||
             '     From ' || p_table_name ||
             '     Where ' || p_col_name || ' = :a1)';
             --dbms_output.put_line('plsql is ' || vPLSQL);
        open valid_id for
            vPlsql
            using p_col_id;
        FETCH valid_id INTO count_id;

        if valid_id%FOUND then
            --dbms_output.put_line('FOUND!!');
            l_return_status := FND_API.G_RET_STS_SUCCESS;
        else
            --dbms_output.put_line('NOT FOUND!!');
            l_return_status := FND_API.G_RET_STS_ERROR;
        end if;
        CLOSE valid_id;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_any_id_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_any_id_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Validate_any_id_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Validate_any_id;

PROCEDURE Validate_any_varchar(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_col_value     IN  VARCHAR2,
                               p_col_name      IN  VARCHAR2,
                               p_table_name    IN  VARCHAR2)
IS

TYPE refCur IS REF CURSOR;
valid_id  refCur;

    l_return_status VARCHAR2(1);
    count_id        VARCHAR2(1);
    l_api_version   NUMBER := p_api_version;
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_api_name      VARCHAR2(20) := 'VALIDATE_ANY_VARCHAR';

    l_col_value varchar2(240);
    vPLSQL varchar2(1000);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_any_varchar_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- API body
        --dbms_output.put_line('col is ' || p_col_value);

        vPLSQL := ' Select ''X''   ' ||
                  ' From ' || p_table_name ||
                  ' Where exists   ' ||
                  '   (Select ' || p_col_name ||
                  '    From ' || p_table_name ||
                  '    Where ' || p_col_name || ' = :a1)';
        --dbms_output.put_line('plsql is ' || vPLSQL);

        OPEN valid_id FOR
            vPLSQL
            using p_col_value;
        FETCH valid_id INTO count_id;

        if valid_id%FOUND then
            --dbms_output.put_line('FOUND!!');
            l_return_status := FND_API.G_RET_STS_SUCCESS;
        else
            --dbms_output.put_line('NOT FOUND!!');
            l_return_status := FND_API.G_RET_STS_ERROR;
        end if;
        CLOSE valid_id;

    x_return_status := l_return_status;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Validate_any_varchar;

PROCEDURE Validate_Lookup_CODE(p_api_version   IN  NUMBER := 1.0,
                               p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2,
                               x_return_status OUT NOCOPY VARCHAR2,
                               p_lookup_type   IN  VARCHAR2,
                               p_lookup_code   IN  VARCHAR2,
                               p_lookup_view   IN VARCHAR2 := 'LNS_LOOKUPS')
IS

TYPE refCur IS REF CURSOR;
valid_id  refCur;

    l_return_status VARCHAR2(1);
    count_id        NUMBER       := 0;
    l_api_version   NUMBER       := p_api_version;
    l_init_msg_list VARCHAR2(1)  := p_init_msg_list;
    l_api_name      VARCHAR2(20) := 'VALIDATE_LOOKUP_CODE';

    l_lookup_code varchar2(30);
    l_lookup_type varchar2(30);
    vPLSQL varchar2(1000);

BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT Validate_any_varchar_PVT;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (l_api_version,
                                          p_api_version,
                                          l_api_name,
                                          G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean(p_init_msg_list)
      THEN
          FND_MSG_PUB.initialize;
      END IF;

      -- API body
      l_lookup_code := '''' || p_lookup_code || '''';
      l_lookup_type := '''' || p_lookup_type || '''';

        --dbms_output.put_line('col is ' || l_lookup_code);
        vPLSQL :=
              'Select Count(LOOKUP_CODE) '  ||
              'From ' || p_lookup_view || ' ' ||
              'Where LOOKUP_TYPE = ' || l_lookup_type  || ' AND ' ||
              'LOOKUP_CODE = ' || l_lookup_code || ' AND ' ||
              'ENABLED_FLAG = ''Y''';

        --dbms_output.put_line('plsql is ' || vPLSQL);
        OPEN valid_id FOR
            vPLSQL;
        FETCH valid_id INTO count_id;

        CLOSE valid_id ;

        IF (count_id > 0) then
                l_return_status := FND_API.G_RET_STS_SUCCESS;
        ELSE
                l_return_status := FND_API.G_RET_STS_ERROR;
        END IF ;
    x_return_status := l_return_status;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO Validate_any_varchar_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
            FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
        END IF;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);

END Validate_LOOKUP_CODE;

Procedure getObjectVersion(p_table_name            IN varchar2
                          ,p_primary_key_name      IN varchar2
                          ,p_primary_key_value     IN NUMBER
                          ,p_object_version_number IN NUMBER
                          ,x_object_version_number OUT NOCOPY NUMBER
                          ,x_msg_count             OUT NOCOPY NUMBER
                          ,x_msg_data              OUT NOCOPY VARCHAR2
                          ,x_return_status         OUT NOCOPY VARCHAR2)
is
         l_object_version_number number;
         l_rowid  rowid;

    -- check whether record has been updated by another user. If not, lock it.
    BEGIN
        Execute Immediate
        'SELECT OBJECT_VERSION_NUMBER, ' ||
        '       ROWID                  ' ||
        ' FROM   ' || p_table_name       ||
        ' Where '  || p_primary_key_name || ' = ' || p_primary_key_value ||
        ' FOR UPDATE OF ' || p_primary_key_name || ' NOWAIT'
         INTO   l_object_version_number,
               l_rowid;
        IF NOT
            (
             (p_object_version_number IS NULL AND l_object_version_number IS NULL)
             OR
             (p_object_version_number IS NOT NULL AND
              l_object_version_number IS NOT NULL AND
              p_object_version_number = l_object_version_number
             )
            )
        THEN
            FND_MESSAGE.SET_NAME('LNS', 'LNS_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', p_table_name);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        END IF;

        x_object_version_number := nvl(l_object_version_number, 1) + 1;

    EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('LNS', 'LNS_API_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('RECORD', p_primary_key_name);
        FND_MESSAGE.SET_TOKEN('VALUE', NVL(TO_CHAR(p_primary_key_value), 'null'));
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data  => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
        --RAISE FND_API.G_EXC_ERROR;
    END getObjectVersion;


FUNCTION get_lookup_meaning (p_lookup_type  IN VARCHAR2,
                             p_lookup_code  IN VARCHAR2)
 RETURN VARCHAR2 IS
l_meaning lns_lookups.meaning%TYPE;
l_hash_value NUMBER;

BEGIN
  IF p_lookup_code IS NOT NULL AND
     p_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         p_lookup_type||'@*?'||p_lookup_code,
                                         1000,
                                         25000);

    IF pg_lookups_rec.EXISTS(l_hash_value) THEN
        l_meaning := pg_lookups_rec(l_hash_value);
    ELSE

     SELECT meaning
       INTO l_meaning
       FROM lns_lookups
      WHERE lookup_type = p_lookup_type
        AND lookup_code = p_lookup_code ;

     pg_lookups_rec(l_hash_value) := l_meaning;

    END IF;

  END IF;

  return(l_meaning);

EXCEPTION
 WHEN no_data_found  THEN
  return(null);
 WHEN OTHERS THEN
  raise;
END;

function convertAmount(p_from_amount   in number
                      ,p_from_currency in varchar2
                      ,p_to_currency   in varchar2
                      ,p_exchange_type in varchar2
                      ,p_exchange_date in date
                      ,p_exchange_rate in number) return number
is
  l_rate_exists    varchar2(1);
  l_rate           number;
  l_convert_amount number;
  l_to_currency    varchar2(10);
  l_exchange_type  varchar2(25);
  l_exchange_date  date;
  l_precision      number;
  l_api_name       varchar2(25);

  /* --Performance bug#4963583
  cursor c_precision(p_to_currency varchar2) is
  select fndc.precision
      FROM gl_sets_of_books sb,
           fnd_currencies fndc
     WHERE sb.currency_code = fndc.currency_code
       and fndc.currency_code = p_to_currency;
  */
  cursor c_precision(p_to_currency varchar2) is
  select fndc.precision
      FROM fnd_currencies fndc
     WHERE fndc.currency_code = p_to_currency;
begin

  l_api_name := 'convertAmount';
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_amount ' || p_from_amount);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_currency ' || p_from_currency);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_to_currency ' || p_to_currency);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_exchange_type ' || p_exchange_type);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_exchange_date ' || p_exchange_date);
  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_exchange_rate ' || p_exchange_rate);

  if p_to_currency is null then
    SELECT sb.currency_code into l_to_currency
      FROM lns_system_options so,
           gl_sets_of_books sb
    WHERE  sb.set_of_books_id = so.set_of_books_id;
  else
    l_to_currency := p_to_currency ;
  end if;

  if p_exchange_date is null then
     l_exchange_date := sysdate;
  else
     l_exchange_Date := p_exchange_date;
  end if;

  if p_exchange_type = 'User' then
    if p_exchange_rate is null then
        l_convert_amount := -1;
    else
        open c_precision(p_to_currency) ;
        fetch c_precision into l_precision;
        close c_precision;
        l_convert_amount := round(p_from_amount * p_exchange_rate, l_precision);
    end if;

  else
     l_exchange_type := p_exchange_type;
     l_rate_exists := gl_currency_api.rate_exists(X_FROM_CURRENCY   => p_from_currency
                                                 ,X_TO_CURRENCY     => l_to_currency
                                                 ,X_CONVERSION_DATE => l_exchange_date
                                                 ,X_CONVERSION_TYPE => p_exchange_type);
      if l_rate_exists = 'Y' then
      -- rate exists

        /*
          l_rate := gl_currency_api.get_rate(X_FROM_CURRENCY   => p_from_currency,
                                             X_TO_CURRENCY     => p_to_currency,
                                             X_CONVERSION_DATE => p_exchange_date,
                                             X_CONVERSION_TYPE => p_exchange_type);
         */
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_amount ' || p_from_amount);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_from_currency ' || p_from_currency);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_to_currency ' || l_to_currency);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - l_exchange_type ' || l_exchange_type);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_exchange_date ' || p_exchange_date);
          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - p_exchange_rate ' || p_exchange_rate);

          logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' - calling gl_currency API....');
          l_convert_amount := gl_currency_api.convert_amount(X_FROM_CURRENCY   => p_from_currency
                                                            ,X_TO_CURRENCY     => l_to_currency
                                                            ,X_CONVERSION_DATE => l_exchange_date
                                                            ,X_CONVERSION_TYPE => l_exchange_type
                                                            ,X_AMOUNT          => p_from_amount);
       else
          return -1;

       end if;

  end if;

  return l_convert_amount;

end convertAmount;

/*=========================================================================
|| PUBLIC FUNCTION convertRate
||
|| DESCRIPTION
||
|| Overview:  this function will return the rate between 2 currencies for a given date/type
||
|| Parameter: p_from_currency => currency 1
||            p_to_currency   => currency 2
||
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: boolean
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 12/01/2004 1:51PM     raverma           Created
 *=======================================================================*/
function convertRate(p_from_currency in varchar
                    ,p_to_currency   in varchar
                    ,p_exchange_date in date
                    ,p_exchange_type in varchar) return number
is
     l_rate number;
begin

      begin
      l_rate := gl_currency_api.get_rate(X_FROM_CURRENCY   => p_from_currency,
                                         X_TO_CURRENCY     => p_to_currency,
                                         X_CONVERSION_DATE => p_exchange_date,
                                         X_CONVERSION_TYPE => p_exchange_type);
      exception
        WHEN GL_CURRENCY_API.NO_RATE  THEN
            l_rate := -1;

        When others then
            l_rate := -1;

      end;

      return l_rate;
end;


/*=========================================================================
|| PUBLIC FUNCTION Check_PSA_Enabled_Org
||
|| DESCRIPTION
||
|| Overview:  this function will return true if MFAR implemented for org
||
|| Parameter: p_org_id
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: varchar2(1) 'Y' or 'N'
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 01/20/2005 4:51PM     karamach          Changed return type
|| 12/01/2004 1:51PM     raverma           Created
 *=======================================================================*/
function Check_PSA_Enabled_Org(p_org_id in number) return varchar2
is
  l_mfar varchar2(10);
  l_bool boolean := false;

begin
/* 6-3-2005 raverma always return Y
    l_bool := PSA_IMPLEMENTATION.get (p_org_id       => p_org_id
                                     ,p_psa_feature  => 'MFAR'
                                     ,p_enabled_flag => l_mfar);
 */
--    if (l_bool) then
	    return 'Y';
--    end if;

end Check_PSA_Enabled_Org;


/*=========================================================================
|| PUBLIC FUNCTION IS_CREDIT_MANAGEMENT_INSTALLED
||
|| DESCRIPTION
||
|| Overview:  this function will return Y if OCM is installed
||
|| Parameter: none
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: varchar2(1) 'Y' or 'N'
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 07/24/2005 5:51PM     karamach          Created
 *=======================================================================*/
function IS_CREDIT_MANAGEMENT_INSTALLED return varchar2
is
  l_bool boolean := false;

begin

    l_bool := AR_CMGT_CREDIT_REQUEST_API.IS_CREDIT_MANAGEMENT_INSTALLED;
    if (l_bool) then
	    return 'Y';
    end if;

				return 'N';

end IS_CREDIT_MANAGEMENT_INSTALLED;


/*=========================================================================
|| PUBLIC FUNCTION Check_PSA_Enabled_Current_Org
||
|| DESCRIPTION
||
|| Overview:  this function will return true if MFAR implemented for current org
||
|| Parameter: None
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: varchar2(1) 'Y' or 'N'
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 03/02/2005 12:10PM     karamach          Created
 *=======================================================================*/
function Check_PSA_Enabled_Current_Org return varchar2
is
   l_org_id number;
begin

/* 6-3-2005 raverma always return Y
     select org_id into l_org_id
       from lns_system_options;

    return Check_PSA_Enabled_Org(l_org_id);
*/
		return 'Y';

end Check_PSA_Enabled_Current_Org;


/*=========================================================================
|| PUBLIC FUNCTION Check_PSA_Enabled_Loan
||
|| DESCRIPTION
||
|| Overview:  this function will return true if MFAR implemented for loan
||
|| Parameter: p_org_id
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: varchar2(1) 'Y' or 'N'
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 01/20/2005 4:51PM     karamach          Changed return type
|| 12/01/2004 1:51PM     raverma           Created
 *=======================================================================*/
function Check_PSA_Enabled_Loan(p_loan_id number) return varchar2
is
   l_org_id number;
begin

/* 6-3-2005 raverma always return Y
     select org_id into l_org_id
       from lns_loan_headers_all
      where loan_id = p_loan_id;

    return Check_PSA_Enabled_Org(l_org_id);
 */
	 return 'Y';
end Check_PSA_Enabled_Loan;

/*=========================================================================
|| PUBLIC FUNCTION Check_Desc_Flex_Setup
||
|| DESCRIPTION
||
|| Overview:  this function will return 'Y' if the desc flex implemented
||
|| Parameter: p_desc_flex_name
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: varchar2(1) 'Y' or 'N'
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 02/02/2004							     karamach           Created
 *=======================================================================*/
function Check_Desc_Flex_Setup(p_desc_flex_name varchar2) return varchar2
is
  l_bool boolean := false;
begin

    l_bool := FND_FLEX_APIS.is_descr_setup(
    															x_application_id => 206,
    															x_desc_flex_name => p_desc_flex_name);

    if (l_bool) then
					return 'Y';
    end if;

    return 'N';

end Check_Desc_Flex_Setup;


/*=========================================================================
|| PUBLIC FUNCTION getDocumentName
||
|| DESCRIPTION
||
|| Overview:  this function will return the transaction type name for a
||             document type 'PRIN', 'INT', 'FEE'
||
|| Parameter: p_line_type 'PRIN', 'INT', 'FEE'
||
|| Source Tables:  NA
||
|| Target Tables:  NA
||
|| Return value: periodic interest rate on the loan
||
|| KNOWN ISSUES
||
|| NOTES
||
|| MODIFICATION HISTORY
|| Date                  Author            Description of Changes
|| 10/06/2004 1:51PM     raverma           Created
 *=======================================================================*/
function getDocumentName(p_line_type   in varchar2) return varchar2

is
    cursor c_document_type(p_type varchar2)
    is
      select tty.name
        from ra_cust_trx_types tty
             ,lns_system_options lso
       where tty.cust_trx_type_id = decode(p_type, 'PRIN', lso.trx_type_id, 'INT', lso.interest_trx_type_id, 'FEE', lso.fee_trx_type_id);
    l_name varchar2(20);

begin

        OPEN c_document_type(p_line_type);
        FETCH c_document_type INTO l_name;
        close c_document_type;

        return l_name;

exception
         when no_data_found then
            return(null);
end getDocumentName;



FUNCTION Is_Loan_Manager_Role return VARCHAR2 IS

l_loan_manager_flag VARCHAR2(1) ;

BEGIN

SELECT nvl(manager.manager_flag,'N') INTO l_loan_manager_flag
FROM
(SELECT
rol.manager_flag,rel.role_resource_id
FROM
jtf_rs_role_relations rel ,
jtf_rs_roles_b rol
WHERE rel.role_id = rol.role_id
and rel.delete_flag <> 'Y'
and sysdate between nvl(rel.start_date_active,sysdate) and nvl(rel.end_date_active,sysdate)
and rol.role_type_code = 'LOANS'
and rol.role_code = 'LOAN_MGR'
and rol.active_flag = 'Y') manager,
jtf_rs_resource_extns res
WHERE
manager.role_resource_id(+) = res.resource_id
and category = 'EMPLOYEE'
and res.start_date_active <= sysdate
and (res.end_date_active is null or res.end_date_active >= sysdate)
and res.user_id = fnd_global.user_id;

return l_loan_manager_flag ;


END Is_Loan_Manager_Role ;

FUNCTION IS_FED_FIN_ENABLED return VARCHAR2 IS

l_fv_enabled_flag VARCHAR2(1) ;
l_org_id NUMBER ;

BEGIN

    l_fv_enabled_flag := 'N' ;
    BEGIN
        SELECT org_id INTO l_org_id
        FROM lns_system_options so ;

        l_fv_enabled_flag := IS_FED_FIN_ENABLED(l_org_id) ;

    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_fv_enabled_flag := 'N' ;

    END ;

return l_fv_enabled_flag;

END IS_FED_FIN_ENABLED ;

FUNCTION IS_FED_FIN_ENABLED(p_org_id IN NUMBER) return VARCHAR2 IS

l_fv_enabled_flag VARCHAR2(1) ;

BEGIN

    l_fv_enabled_flag := 'N' ;
    BEGIN
        SELECT enable_budgetary_control_flag INTO l_fv_enabled_flag
        FROM gl_ledgers gl, lns_system_options_all so
        WHERE so.org_id = p_org_id
        AND gl.ledger_id = so.set_of_books_id
        AND fnd_profile.value('FV_ENABLED') = 'Y';

    EXCEPTION
	   WHEN NO_DATA_FOUND THEN
		l_fv_enabled_flag := 'N' ;

    END ;

return l_fv_enabled_flag ;

END IS_FED_FIN_ENABLED ;

--This procedure refreshes the materialized view used for graphs
PROCEDURE refresh_mviews(ERRBUF                  OUT NOCOPY VARCHAR2
                        ,RETCODE                 OUT NOCOPY VARCHAR2
                        )
IS
   l_api_name CONSTANT VARCHAR2(30) := 'REFRESH_MVIEWS';
   l_entity_name CONSTANT VARCHAR2(30) := 'LNS_LOAN_DTLS_ALL_MV';

  --This cursor is used to check if the mv exists already
  CURSOR Check_MV_Exists(p_mv_name VARCHAR2) IS
  SELECT MVIEW_NAME,COMPILE_STATE
  FROM USER_MVIEWS
  WHERE MVIEW_NAME = p_mv_name;

  --This is used for the cursor Check_MV_Exists
  l_mv_name 		VARCHAR2(200);
  l_compile_state	VARCHAR2(200);
  l_return    boolean;
BEGIN

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' :BEGIN');

  OPEN Check_MV_Exists(l_entity_name);
  FETCH Check_MV_Exists INTO l_mv_name,l_compile_state;
  CLOSE Check_MV_Exists;

  if (l_mv_name is not null) then

    fnd_file.put_line(FND_FILE.LOG,
		'Begin dbms_mview.refresh call to refresh data in '|| l_entity_name);
    dbms_mview.refresh(l_entity_name, 'C', '', TRUE, FALSE, 0,0,0, TRUE);

    fnd_file.put_line(FND_FILE.LOG,
		'Completed dbms_mview.refresh call to refresh data in '|| l_entity_name);

    --This statement added as workaround for bug#2695199/2639679
    --MATERIALIZED VIEWS BECOME INVALID AFTER ALTER OR REFRESH
    if (l_compile_state <> 'VALID') then
       execute immediate
         ' alter materialized view '||l_entity_name||' compile';
    end if; --if (l_compile_state <> 'VALID') then

  else

  	logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' : Materialized View '|| l_entity_name || 'NOT FOUND - nothing to refresh');
         fnd_file.put_line(FND_FILE.LOG,
                'Materialized View '|| l_entity_name || 'NOT FOUND - nothing to refresh');
         fnd_file.put_line(FND_FILE.LOG,
                'Exiting program without performing any action');
        RETCODE := 'E';
	ERRBUF := 'Materialized View '|| l_entity_name || 'NOT FOUND - nothing to refresh';
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => 'ERROR',
                        message => 'Materialized View Refresh has failed. Please review log file.');

  end if; --if (l_mv_name is not null) then

  logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' :END');

EXCEPTION
     when others then
	fnd_file.put_line(FND_FILE.LOG,
			'Exception in refreshing MVs: '||sqlerrm);
        RETCODE := 'E';
        ERRBUF := 'Exception in refreshing MVs: '||sqlerrm;
        l_return := FND_CONCURRENT.SET_COMPLETION_STATUS(
                        status => 'ERROR',
                        message => 'Materialized View Refresh has failed. Please review log file.');
	--raise;
END refresh_mviews;

--This function checks if a concurrent program request is pending/running
--Returns 'N' if there are no pending/running requests for the conc program
FUNCTION is_concurrent_request_pending
  (p_application_short_name  IN VARCHAR2,
   p_concurrent_program_name IN VARCHAR2)
RETURN varchar2
IS
   l_api_name     CONSTANT VARCHAR2(30) := 'IS_CONCURRENT_REQUEST_PENDING';
   l_is_pending  Varchar2(1);
   l_request_id NUMBER;
   CURSOR C_CHECK_CP_REQ IS
   select request_id
          FROM fnd_concurrent_requests fcr,
               fnd_concurrent_programs fcp,
               fnd_application fa
          WHERE fa.application_short_name = p_application_short_name
          AND fcp.application_id = fa.application_id
          AND fcp.concurrent_program_name = p_concurrent_program_name
          AND fcr.program_application_id = fcp.application_id
          AND fcr.concurrent_program_id  = fcp.concurrent_program_id
          --AND fcr.status_code in ('I', 'Q', 'R') --fnd_lookups CP_STATUS_CODE
          AND fcr.phase_code <> 'C' --fnd_lookups CP_PHASE_CODE
          AND ROWNUM = 1;

BEGIN
   l_is_pending := 'N';

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' :BEGIN');

   open C_CHECK_CP_REQ;
   fetch C_CHECK_CP_REQ into l_request_id;
   close C_CHECK_CP_REQ;

   if (l_request_id IS NOT NULL) then
	l_is_pending := 'Y';
   end if;

   logMessage(FND_LOG.LEVEL_PROCEDURE, G_PKG_NAME, l_api_name || ' :END');

   return l_is_pending;

END is_concurrent_request_pending;

END LNS_UTILITY_PUB;

/
