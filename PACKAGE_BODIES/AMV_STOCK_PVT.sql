--------------------------------------------------------
--  DDL for Package Body AMV_STOCK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMV_STOCK_PVT" AS
/* $Header: amvvstkb.pls 120.1 2005/06/21 16:53:03 appldev ship $ */
--
-- NAME
--   AMV_STOCK_PVT
--
-- HISTORY
--   11/10/1999        SLKRISHN        CREATED
--
--
G_PKG_NAME 	CONSTANT VARCHAR2(30) := 'AMV_STOCK_PVT';
G_FILE_NAME	CONSTANT VARCHAR2(12) := 'amvvstkb.pls';
--
TYPE CursorType IS REF CURSOR;
----------------------------- Private Portion ---------------------------------
--------------------------------------------------------------------------------
-- We use the following private utility procedures
--------------------------------------------------------------------------------
--
PROCEDURE Update_Symbols
(
     p_user_id    		IN  NUMBER,
	p_symbols_array	IN amv_char_varray_type
);
--
PROCEDURE Get_UserSymbols
(
     p_user_id    		IN  NUMBER,
	x_symbol_array		OUT NOCOPY  AMV_SYM_VARRAY_TYPE
);
--
FUNCTION Is_UserIdValid
(
	p_user_id		IN NUMBER
) RETURN Boolean;
--
PROCEDURE Parse_Symbols (p_symbols		 IN	varchar2,
					x_symbols_array OUT NOCOPY 	amv_char_varray_type );
--
PROCEDURE Parse_Stock (	p_symbol	IN  VARCHAR2,
					x_symbol	OUT NOCOPY  VARCHAR2,
					x_type 	OUT NOCOPY  VARCHAR2 );
--
PROCEDURE Add_UserStocks
(
 p_user_id			IN  NUMBER,
 p_symbols_array  		IN  AMV_CHAR_VARRAY_TYPE,
 x_return_status                OUT NOCOPY  VARCHAR2
);
--
PROCEDURE Delete_UserStocks
(
 p_tickerid_array  		IN  AMV_NUM_VARRAY_TYPE
);
--
FUNCTION Get_SBPId RETURN NUMBER;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Update_Symbols
--    Type       : Private
--    Pre-reqs   : None
--    Function   : update user tickers last update date for getting them back in the order stored
--    Parameters :
--            IN : p_user_id    		IN  NUMBER  Required
--	         IN : p_symbols_array		IN AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Update_Symbols
(
	p_user_id    		IN  NUMBER,
	p_symbols_array	IN amv_char_varray_type
)
IS
l_stock_id number;
l_symbol 	varchar2(20);
l_null	varchar2(30) := null;
l_rec_num	number := 0;

CURSOR Get_StockId IS
select stock_id
from   amv_stocks
where  stock_symbol = l_symbol;
--
BEGIN
  	FOR i in 1..p_symbols_array.count LOOP
	 	--
	 	l_symbol := p_symbols_array(i);
	 	OPEN Get_StockId;
	 		FETCH Get_StockId INTO l_stock_id;
	 	CLOSE Get_StockId;

	 	UPDATE amv_user_ticker
	 	SET last_update_date = sysdate + i
	 	WHERE user_id = p_user_id
	 	AND   stock_id = l_stock_id;
	 	--
	END LOOP;
    --
END Update_Symbols;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_UserSymbols
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns an array of stocks for an user.
--    Parameters :
--            IN : p_user_id    		IN  NUMBER  Required
--	        OUT : x_symbol_array		OUT AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Get_UserSymbols
(
	p_user_id    	IN  NUMBER,
	x_symbol_array	OUT NOCOPY  AMV_SYM_VARRAY_TYPE
)
IS
l_stock_id number;
l_symbol 	varchar2(20);
l_null	varchar2(30) := null;
l_rec_num	number := 0;
--
CURSOR Get_UserSymbols_csr IS
select amut.user_ticker_id
,  	  amst.stock_symbol
,	  l_null
from	amv_user_ticker amut
,	amv_stocks amst
where	amut.user_id = p_user_id
and   	amut.stock_id = amst.stock_id;

BEGIN
    IF p_user_id = FND_API.G_MISS_NUM OR
       p_user_id IS NULL THEN
	  l_rec_num := null;
	  --RAISE;
    ELSE
    	OPEN Get_UserSymbols_csr;
		LOOP
			l_rec_num := l_rec_num + 1;
      		FETCH Get_UserSymbols_csr INTO x_symbol_array(l_rec_num);
	 		EXIT WHEN Get_UserSymbols_csr%NOTFOUND;
     	END LOOP;
    	CLOSE Get_UserSymbols_csr;
   	--
    END IF;
    --
END Get_UserSymbols;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Is_UserIdValid
--    Type       : Private
--    Pre-reqs   : None
--    Function   : checks user id
--    Parameters :
--            IN : p_user_id    		IN  NUMBER  Required
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Is_UserIdValid
(
	p_user_id		IN NUMBER
) RETURN Boolean
IS
l_valid_flag	number;
--
CURSOR Check_UserId_csr IS
select count(*)
from   fnd_user
where  user_id = p_user_id;
BEGIN
	OPEN Check_UserId_csr;
		FETCH Check_UserId_csr INTO l_valid_flag;
	CLOSE Check_UserId_csr;
	IF l_valid_flag > 0 THEN
		return TRUE;
	ELSE
		return FALSE;
	END IF;
END Is_UserIdValid;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Parse_Symbols
--    Type       : Private
--    Pre-reqs   : None
--    Function   : parses stock symbols into a varchar2 table
--    Parameters :
--            IN : p_symbols    		IN  VARCHAR2  Required
--	            : x_symbols_array		OUT AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Parse_Symbols (p_symbols		 IN	varchar2,
					x_symbols_array OUT NOCOPY 	amv_char_varray_type )
IS
l_ins 			number := 1;
l_str 			number := 1;
l_sym_num 		number := 1;
l_rec_num 		number := 1;
l_symbol			varchar2(20);
l_err_msg			varchar2(100);
BEGIN
    	-- build symbols array
    	while l_ins > 0 loop
		l_ins := instr(p_symbols, ',', 1, l_sym_num);

		if l_ins = 0 then
			l_symbol := substr(p_symbols, l_str);
		else
			l_symbol := substr(p_symbols, l_str, l_ins - l_str );
		end if;

		IF rtrim(l_symbol) is not null THEN
			x_symbols_array(l_rec_num) := upper(l_symbol);
			l_rec_num := l_rec_num + 1;
		END IF;
		l_sym_num := l_sym_num + 1;
		l_str := l_ins + 1;
    	end loop;
    	--
EXCEPTION
 WHEN OTHERS THEN
	l_err_msg := 'Error_Parsing_Symbol';
END Parse_Symbols;
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Parse_Stock
--    Type       : Private
--    Pre-reqs   : None
--    Function   : parses stock symbol to remove foreign stock identifier
--    Parameters :
--            IN : p_symbol    	IN  VARCHAR2  Required
--	            : x_symbol		OUT NOCOPY  VARCHAR2
--			    x_type		OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Parse_Stock (	p_symbol	IN  VARCHAR2,
					x_symbol	OUT NOCOPY  VARCHAR2,
					x_type 	OUT NOCOPY  VARCHAR2 )
IS
l_ins 			number := 1;
l_sym_num 		number := 1;
l_err_msg			varchar2(100);
BEGIN
     -- parse stock symbol
	while l_ins > 0 loop
		l_ins := instr(p_symbol, '.', 1, l_sym_num);
		if l_ins = 0 then
		 	if l_sym_num = 1 then
			 	x_symbol := p_symbol;
			 	x_type := null;
	  		end if;
		else
		  	x_symbol := substr(p_symbol, 1, l_ins-1);
		  	x_type := substr(p_symbol, l_ins + 1);
		end if;
		l_sym_num := l_sym_num + 1;
	end loop;
    	--
EXCEPTION
 WHEN OTHERS THEN
	l_err_msg := 'Error_Parsing_Stock';
END Parse_Stock;
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Add_UserStocks
--    Type       : Private
--    Pre-reqs   : None
--    Function   : adds stcoks to user list
--    Parameters :
--            IN : p_user_id    		IN  NUMBER  Required
--	            : p_symbol_array		IN AMV_CHAR_VARRAY_TYPE
--            OUT NOCOPY : x_return_status OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Add_UserStocks
(
 p_user_id			IN  NUMBER,
 p_symbols_array  		IN  AMV_CHAR_VARRAY_TYPE,
 x_return_status                OUT NOCOPY  VARCHAR2
)
IS
l_user_id     			number := p_user_id;
l_login_user_id     	number := p_user_id;
l_object_version_number	number := 1;
--
l_symbol			varchar2(20);
l_stock_id		number;
l_user_ticker_id	number;
l_miss_rec		number := 0;

CURSOR Get_StockId IS
select stock_id
from	  amv_stocks
where  stock_symbol = l_symbol;

CURSOR UserTicker_seq IS
SELECT amv_user_ticker_s.nextval
FROM   dual;

BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;
	FOR i in 1..p_symbols_array.count LOOP
	    l_symbol := p_symbols_array(i);
	    -- get stock id's
	     OPEN Get_StockId;
	     	FETCH Get_StockId INTO l_stock_id;
	     CLOSE Get_StockId;

	    -- insert stock ticker if stock id is not null
	    IF l_stock_id is not null THEN
	 		OPEN UserTicker_seq;
	   			FETCH UserTicker_seq INTO l_user_ticker_id;
	  		CLOSE UserTicker_seq;
			--
			BEGIN
		  	  INSERT INTO amv_user_ticker
		  	  (
				user_ticker_id,
				object_version_number,
				last_update_date,
				last_updated_by,
				creation_date,
				created_by,
				last_update_login,
				user_id,
				stock_id
		  	  )
		  	  VALUES
		  	  (
				l_user_ticker_id,
				l_object_version_number,
				sysdate,
				l_user_id,
				sysdate,
				l_user_id,
				l_login_user_id,
				p_user_id,
				l_stock_id
		  	  );
			EXCEPTION
			 WHEN OTHERS THEN
				l_miss_rec := l_miss_rec + 1;
			END;
			--
			l_stock_id := null;
	    ELSE
		 x_return_status := FND_API.G_RET_STS_ERROR;
	    END IF;
	END LOOP;
	--

END Add_UserStocks;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Delete_UserStocks
--    Type       : Private
--    Pre-reqs   : None
--    Function   : deletes stcoks from user list
--    Parameters :
--            IN : p_user_id    		IN  NUMBER  Required
--	            : p_symbol_array		IN AMV_CHAR_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
PROCEDURE Delete_UserStocks
(
 p_tickerid_array  		IN  AMV_NUM_VARRAY_TYPE
)
IS
BEGIN
    --
    FOR i in 1..p_tickerid_array.count LOOP
		DELETE FROM amv_user_ticker
		where  user_ticker_id = p_tickerid_array(i);
    END LOOP;
    --
END Delete_UserStocks;
--
--------------------------------------------------------------------------------
--
-- Start of comments
--    API name   : Get_SBPId
--    Type       : Private
--    Pre-reqs   : None
--    Function   : returns stand alone batch process id
--    Parameters :
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
-- End of comments
--
FUNCTION Get_SBPId RETURN NUMBER
IS
l_id		number;
CURSOR Get_SBPId_csr IS
select user_id
from   fnd_user
where  user_name = 'STANDALONE BATCH PROCESS';

BEGIN
    --
    OPEN Get_SBPId_csr;
    	FETCH Get_SBPId_csr INTO l_id;
	IF Get_SBPId_csr%NOTFOUND THEN
		l_id := -1;
	END IF;
    CLOSE Get_SBPId_csr;
    --
    return l_id;
    --
END Get_SBPId;
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserTicker
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Returns the list of tickers for an user
--    Parameters :
--    IN           p_api_version            IN  NUMBER    Required
--                 p_init_msg_list          IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level       IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_user_id                IN  NUMBER    Required
--                 p_sort_order             IN  VARCHAR2  Optional
--    OUT NOCOPY         : x_return_status          OUT NOCOPY  VARCHAR2
--                 x_msg_count              OUT NOCOPY  NUMBER
--                 x_msg_data               OUT NOCOPY  VARCHAR2
--		   	    x_ticker_array	    OUT NOCOPY  AMV_STK_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserTicker
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_user_id     		IN  NUMBER,
      p_distinct_stocks        IN VARCHAR2 := FND_API.G_FALSE,
      p_sort_order			IN  VARCHAR2 := FND_API.G_MISS_CHAR,
      x_stkpr_array    		OUT NOCOPY  AMV_STK_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_UserTicker';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id		number := -1;
l_login_user_id		number := -1;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_stock_id number;
l_stock_symbol varchar2(30);
l_last_update_date date;
l_symbol	varchar2(20);
l_desc	varchar2(240);
l_price	number;
l_change	number;
l_rec_num	number := 0;

l_select_stmt  varchar2(200);
l_from_stmt	varchar2(150);
l_where_clause varchar2(200);
l_order_by	varchar2(50);
l_sql_statement varchar2(600);

l_cursor	CursorType;
--
CURSOR Get_StockData_csr IS
select amst.stock_id
,  	  amst.stock_symbol
,      amst.stock_desc
,      amsp.stock_price
,      amsp.change
from   amv_stocks amst
,      amv_stock_price amsp
where  amst.stock_ric = amsp.stock_ric(+)
and    amst.stock_id = l_stock_id
order  by amsp.time_stamp desc;

CURSOR Get_DistinctUserStocks_csr IS
select distinct amst.stock_symbol, amut.stock_id
from   amv_user_ticker amut
,	  amv_stocks amst
where  amut.user_id = p_user_id
and	  amut.stock_id = amst.stock_id
order by amst.stock_symbol ASC;
--order by l_order_by;

CURSOR Get_UserStocks_csr IS
select amut.stock_id
from   amv_user_ticker amut
,	  amv_stocks amst
where  amut.user_id = p_user_id
and	  amut.stock_id = amst.stock_id
order by amst.stock_symbol ASC;
--order by l_order_by;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_UserTicker;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    --IF Is_UserIdValid(p_user_id) THEN
    --
    IF p_distinct_stocks = FND_API.G_FALSE THEN
	l_select_stmt := 'SELECT amst.stock_symbol, amut.stock_id, amut.last_update_date ';
    ELSE
	l_select_stmt := 'SELECT distinct amst.stock_symbol, amut.stock_id, amut.last_update_date ';
    END IF;

    l_from_stmt := 'FROM   amv_user_ticker amut, amv_stocks amst ';
    l_where_clause := 'WHERE  amut.user_id = :user_id ';
    l_where_clause := l_where_clause || 'AND	 amut.stock_id = amst.stock_id ';

    IF p_sort_order = FND_API.G_MISS_CHAR OR
	  p_sort_order IS NULL
    THEN
	l_order_by := 'ORDER BY amut.last_update_date ASC';
    ELSE
	l_order_by := 'ORDER BY amst.stock_symbol ' || p_sort_order;
    END IF;

    l_sql_statement := l_select_stmt || l_from_stmt || l_where_clause || l_order_by;

    OPEN l_cursor FOR l_sql_statement USING p_user_id;
	  LOOP
		FETCH l_cursor INTO  l_stock_symbol, l_stock_id, l_last_update_date;
		EXIT WHEN l_cursor%NOTFOUND;
		IF l_stock_id is not null THEN
		  OPEN Get_StockData_csr;
			l_rec_num := l_rec_num + 1;
			FETCH Get_StockData_csr INTO x_stkpr_array(l_rec_num);
		  CLOSE Get_StockData_csr;
		  l_stock_id := null;
		END IF;
	  END LOOP;
    CLOSE l_cursor;

/*
    IF p_distinct_stocks = FND_API.G_FALSE THEN
	OPEN Get_UserStocks_csr;
	  LOOP
		FETCH Get_UserStocks_csr INTO l_stock_id;
		EXIT WHEN Get_UserStocks_csr%NOTFOUND;
		IF l_stock_id is not null THEN
		  OPEN Get_StockData_csr;
			l_rec_num := l_rec_num + 1;
			FETCH Get_StockData_csr INTO x_stkpr_array(l_rec_num);
		  CLOSE Get_StockData_csr;
		  l_stock_id := null;
		END IF;
	  END LOOP;
	CLOSE Get_UserStocks_csr;
    ELSE
	OPEN Get_DistinctUserStocks_csr;
	  LOOP
		FETCH Get_DistinctUserStocks_csr INTO l_stock_symbol, l_stock_id;
		EXIT WHEN Get_DistinctUserStocks_csr%NOTFOUND;
		IF l_stock_id is not null THEN
		  OPEN Get_StockData_csr;
			l_rec_num := l_rec_num + 1;
			FETCH Get_StockData_csr INTO x_stkpr_array(l_rec_num);
		  CLOSE Get_StockData_csr;
		  l_stock_id := null;
		END IF;
	  END LOOP;
	CLOSE Get_DistinctUserStocks_csr;
    END IF;
*/
    --
    --ELSE
     --     -- User Id is not valid.
     --     IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
     --        FND_MESSAGE.Set_name('AMV','AMV_USER_ID_INVALID');
	--	     FND_MESSAGE.Set_Token('TKN',p_user_id);
     --        FND_MSG_PUB.Add;
     --    END IF;
     --    RAISE  FND_API.G_EXC_ERROR;
    -- END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_UserTicker;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_UserTicker;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_UserTicker;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_UserTicker;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_StockDetails
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Returns the ticker details for list of stocks
--    Parameters :
--    IN           p_api_version            IN  NUMBER    Required
--                 p_init_msg_list          IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level       IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_symbols                IN  VARCHAR2  Required
--    OUT NOCOPY         : x_return_status          OUT NOCOPY  VARCHAR2
--                 x_msg_count              OUT NOCOPY  NUMBER
--                 x_msg_data               OUT NOCOPY  VARCHAR2
--		   	    x_ticker_array	    OUT NOCOPY  AMV_STK_VARRAY_TYPE
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_StockDetails
(     p_api_version          	IN  NUMBER,
      p_init_msg_list        	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level  	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status        	OUT NOCOPY  VARCHAR2,
      x_msg_count            	OUT NOCOPY  NUMBER,
      x_msg_data             	OUT NOCOPY  VARCHAR2,
      p_symbols     		IN  VARCHAR2,
      x_stkpr_array    		OUT NOCOPY  AMV_STK_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_StockDetails';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id		number := -1;
l_login_user_id		number := -1;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_stock_id number;
l_symbol varchar2(20);
l_description varchar2(240);
l_price	number;
l_change	number;
l_symbols_array	amv_char_varray_type;
l_rec_num	number := 0;
l_stock_symbol varchar2(30);
--
CURSOR Get_Stocks_csr IS
select amst.stock_id
,	  amst.stock_symbol
,      amst.stock_desc
,      amsp.stock_price
,      amsp.change
from   amv_stocks amst
,      amv_stock_price amsp
where  amst.stock_symbol = l_stock_symbol
and    amst.stock_ric = amsp.stock_ric(+)
order  by amsp.time_stamp desc;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_StockDetails;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    -- parse symbols into a table
    Parse_Symbols(p_symbols, l_symbols_array);

    --
    FOR i in 1..l_symbols_array.count LOOP
	l_stock_symbol := l_symbols_array(i);
	l_stock_id := null;
	IF l_stock_symbol is not null THEN
       OPEN Get_Stocks_csr;
		FETCH Get_Stocks_csr INTO l_stock_id, l_symbol,
							 l_description, l_price, l_change;
		IF l_stock_id is not null then
		  l_rec_num := l_rec_num + 1;
		  x_stkpr_array(l_rec_num).stock_id := l_stock_id;
		  x_stkpr_array(l_rec_num).symbol := l_symbol;
		  x_stkpr_array(l_rec_num).description := l_description;
		  x_stkpr_array(l_rec_num).price := l_price;
		  x_stkpr_array(l_rec_num).change := l_change;
          END IF;
       CLOSE Get_Stocks_csr;
     END IF;
    END LOOP;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_StockDetails;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_StockDetails;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_StockDetails;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_StockDetails;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Update_UserTicker
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Update the tickers for an user
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_object_version_number  	IN  NUMBER    Required
--                      object version number
--                 p_user_id                	IN  NUMBER    Required
--                    user id.
--                 p_symbols        		IN  VARCHAR2  Required
--                    stock symbols.
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Update_UserTicker
(     p_api_version     		IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data        	 	OUT NOCOPY  VARCHAR2,
      p_object_version_number IN  NUMBER,
      p_user_id          	IN  NUMBER,
      p_symbols      		IN  VARCHAR2
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Update_UserTicker';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name        	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id     		number := p_user_id;
l_login_user_id     	number := p_user_id;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_symbols_array	amv_char_varray_type;
l_user_symbols		amv_sym_varray_type;
l_add_symbols		amv_char_varray_type;
l_del_symbols		amv_num_varray_type;
l_upd_symbols		amv_num_varray_type;
l_stock_id		number;
l_rec_num 		number := 0;
l_upd_num 		number := 0;
l_flag		 	varchar2(20);
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Update_UserTicker;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    --IF Is_UserIdValid(p_user_id) THEN
	--
	-- parse user tickers to an varchar2 table
	Parse_Symbols( p_symbols => p_symbols,
			    x_symbols_array => l_symbols_array);

     -- get the existing user stocks
    	Get_UserSymbols( p_user_id, l_user_symbols);

    	-- build the list of new symbols
    	l_flag := 'ADDED';
    	FOR i in 1..l_symbols_array.count LOOP
		FOR j in 1..l_user_symbols.count LOOP
			IF l_user_symbols(j).exchange is null THEN
			 IF l_symbols_array(i) = l_user_symbols(j).symbol THEN
				l_flag := 'EXISTS';
				l_stock_id := l_user_symbols(j).stock_id;
				l_user_symbols(j).exchange := 'T';
			 ELSE
				l_flag := 'ADDED';
			 END IF;
			EXIT WHEN l_symbols_array(i)=l_user_symbols(j).symbol;
			END IF;
		END LOOP;
		IF l_flag = 'EXISTS' THEN
			l_upd_num := l_upd_num + 1;
			l_upd_symbols(l_upd_num) := l_stock_id;
			l_flag := 'ADDED';
		ELSIF l_flag = 'ADDED' THEN
			l_rec_num := l_rec_num + 1;
			l_add_symbols(l_rec_num) := l_symbols_array(i);
		END IF;
    	END LOOP;

    	-- initialize rec num
    	l_rec_num := 0;

    	-- build the list of deleted symbols
    	FOR i in 1..l_user_symbols.count LOOP
		IF l_user_symbols(i).exchange is null THEN
				l_rec_num := l_rec_num + 1;
				l_del_symbols(l_rec_num) := l_user_symbols(i).stock_id;
		END IF;
    	END LOOP;

    	IF l_add_symbols.count > 0 THEN
		  Add_UserStocks(
 				p_user_id	=> p_user_id,
 				p_symbols_array => l_add_symbols,
				x_return_status => x_return_status
		  );
    	END IF;

    	IF l_del_symbols.count > 0 THEN
		  Delete_UserStocks( p_tickerid_array => l_del_symbols );
    	END IF;

     -- update the last update date to get stocks based on the order stores by user
	Update_Symbols( p_user_id, l_symbols_array);

    --ELSE
     --     -- User Id is not valid.
     --     IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
     --       FND_MESSAGE.Set_name('AMV','AMV_USER_ID_INVALID');
	--	    FND_MESSAGE.Set_Token('TKN',p_user_id);
     --       FND_MSG_PUB.Add;
     --     END IF;
     --     RAISE  FND_API.G_EXC_ERROR;
    --END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Update_UserTicker;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Update_UserTicker;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Update_UserTicker;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Update_UserTicker;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_VendorMissedStocks
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Gets the list of stocks for which the vendor keys have not
--			been identified
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id                	IN  NUMBER    Required
--                    vendor id.
--                 p_start_index                  IN  NUMBER   Optional
--                        Default = 1
--                 p_batch_size                   IN  NUMBER   Optional
--                        Default = FND_API.G_MISS_NUM
--                    batch size of keys.
--    OUT NOCOPY         : x_return_status       OUT NOCOPY  VARCHAR2
--                 x_msg_count           OUT NOCOPY  NUMBER
--                 x_msg_data            OUT NOCOPY  VARCHAR2
--                 x_stocks_array        OUT NOCOPY  AMV_SYM_VARRAY_TYPE  Required
--                    stock symbol and ric.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_VendorMissedStocks
(     p_api_version     		IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data        		OUT NOCOPY  VARCHAR2,
      p_vendor_id          	IN  NUMBER,
	 p_start_index			IN NUMBER := 1,
	 p_batch_size		     IN NUMBER := FND_API.G_MISS_NUM,
      x_stocks_array      	OUT NOCOPY  AMV_SYM_VARRAY_TYPE
)
IS
l_api_name         	CONSTANT VARCHAR2(30) := 'Get_VendorMissedStocks';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name        	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id     		number := -1;
l_login_user_id     	number := -1;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_stock_id	number;
l_rec_num		number := 0;

CURSOR Get_VenMissStk_csr IS
select a.stock_id
from amv_stocks a
where a.stock_id > p_start_index
minus
select b.stock_id
from amv_vendor_keys b
where b.vendor_id = p_vendor_id
order by 1;

CURSOR Get_StocksInfo_csr IS
select stock_id
,	stock_symbol
,	exchange
from	amv_stocks
where  stock_id = l_stock_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_VendorMissedStocks;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    OPEN Get_VenMissStk_csr;
     LOOP
	  l_rec_num := l_rec_num + 1;
    	  FETCH Get_VenMissStk_csr INTO l_stock_id;
	  EXIT WHEN Get_VenMissStk_csr%NOTFOUND;
	  --
	  IF l_stock_id is not null THEN
	  	OPEN Get_StocksInfo_csr;
	  		FETCH Get_StocksInfo_csr INTO x_stocks_array(l_rec_num);
	 	CLOSE Get_StocksInfo_csr;
	  END IF;
	  --
	  IF p_batch_size <> FND_API.G_MISS_NUM THEN
		EXIT WHEN l_rec_num = p_batch_size;
	  END IF;
     END LOOP;
    CLOSE Get_VenMissStk_csr;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_VendorMissedStocks;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_VendorMissedStocks;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_VendorMissedStocks;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_VendorMissedStocks;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Insert_StockVendorKeys
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Inserts the Stock id and the vendor id and key id for vendor
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id           IN  NUMBER    Required
--                    vendor id.
--                 p_ticker_rec        IN  AMV_TKR_OBJ_TYPE  Required
--                    ticker array (ric and key id).
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Insert_StockVendorKeys
(     p_api_version     	IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data        	OUT NOCOPY  VARCHAR2,
      p_vendor_id          	IN  NUMBER,
      p_ticker_rec      	IN  AMV_TKR_OBJ_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Insert_StockVendorKeys';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id     		number := Get_SBPId;
l_login_user_id     	number := Get_SBPId;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_key_id		varchar2(60);
l_vendor_key_id		number;
l_stock_id		number;
l_stock_key_id		number;
l_miss_rec		number := 0;
l_object_version_number	number := 1;

CURSOR VendorKeyId_seq IS
select amv_vendor_keys_s.nextval
from dual;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Insert_StockVendorKeys;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    l_key_id := p_ticker_rec.key_id;
    l_stock_id := p_ticker_rec.stock_id;

    IF l_stock_id is not null AND l_key_id is not null THEN
	  OPEN VendorKeyId_seq;
		FETCH VendorKeyId_seq INTO l_vendor_key_id;
	  CLOSE VendorKeyId_seq;

	  BEGIN
	   INSERT INTO amv_vendor_keys(
		vendor_key_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		vendor_id,
		vendor_key,
		stock_id,
		effective_start_date
	   )
	   VALUES (
		l_vendor_key_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_user_id,
		p_vendor_id,
		l_key_id,
		l_stock_id,
		sysdate
	   );
	  EXCEPTION
	   WHEN OTHERS THEN
		-- NOTE Add Message
		l_miss_rec := l_miss_rec + 1;
	  END;
    ELSE
		-- NOTE Add Message
		l_miss_rec := l_miss_rec + 1;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Insert_StockVendorKeys;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Insert_StockVendorKeys;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Insert_StockVendorKeys;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Insert_StockVendorKeys;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_UserSelectedKeys
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Gives an array of all the stocks selected by all users
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--		   p_vendor_id		IN NUMBER Required
--			vendor id
--    OUT NOCOPY         : x_return_status     OUT NOCOPY  VARCHAR2
--                 x_msg_count         OUT NOCOPY  NUMBER
--                 x_msg_data          OUT NOCOPY  VARCHAR2
--                 x_keys_array        OUT NOCOPY   AMV_CHAR_VARRAY_TYPE  Required
--                    key id.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_UserSelectedKeys
(     p_api_version     	IN  NUMBER,
      p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    OUT NOCOPY  VARCHAR2,
      x_msg_count        OUT NOCOPY  NUMBER,
      x_msg_data        	OUT NOCOPY  VARCHAR2,
      p_vendor_id        IN NUMBER,
	 p_all_keys		IN VARCHAR2 := FND_API.G_FALSE,
      x_keys_array      	OUT NOCOPY   AMV_CHAR_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_UserSelectedKeys';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id     		number := -1;
l_login_user_id     	number := -1;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_key_id	varchar2(60);
l_rec_num	number := 0;
l_symbols	varchar2(400);
l_stock_symbol	varchar2(20);
l_profile_name	varchar2(30) := 'AMV_DEFAULT_STOCK';
l_symbols_array amv_char_varray_type;

CURSOR Get_UserKeys_csr IS
select 	distinct amvk.vendor_key
from   	amv_vendor_keys amvk
,		amv_user_ticker amut
where	amut.stock_id = amvk.stock_id
and		amvk.vendor_id = p_vendor_id;

CURSOR Get_SymKeys_csr IS
select 	amvk.vendor_key
from   	amv_vendor_keys amvk
,		amv_stocks amst
where	amst.stock_symbol = l_stock_symbol
and		amst.stock_id = amvk.stock_id;

CURSOR Get_AllKeys_csr IS
select 	distinct amvk.vendor_key
from   	amv_vendor_keys amvk
where	amvk.vendor_id = p_vendor_id;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_UserSelectedKeys;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    IF p_all_keys = FND_API.G_TRUE THEN
	-- get all keys
    	OPEN Get_AllKeys_csr;
      LOOP
		l_rec_num := l_rec_num + 1;
    		FETCH Get_AllKeys_csr INTO x_keys_array(l_rec_num);
		EXIT WHEN Get_AllKeys_csr%NOTFOUND;
      END LOOP;
    	CLOSE Get_AllKeys_csr;
    ELSE
	-- get user selected keys
    	OPEN Get_UserKeys_csr;
      LOOP
		l_rec_num := l_rec_num + 1;
    		FETCH Get_UserKeys_csr INTO x_keys_array(l_rec_num);
		EXIT WHEN Get_UserKeys_csr%NOTFOUND;
      END LOOP;
    	CLOSE Get_UserKeys_csr;
    	--
    	-- get default stocks from profile option values
    	FND_PROFILE.Get(l_profile_name, l_symbols);
    	-- parse the profile symbols
    	IF l_symbols is not null THEN
		Parse_Symbols(l_symbols, l_symbols_array);
    	END IF;

    	FOR i in 1..l_symbols_array.count LOOP
	l_stock_symbol := l_symbols_array(i);
		OPEN Get_SymKeys_csr;
			FETCH Get_SymKeys_csr INTO l_key_id;
			IF l_key_id is not null THEN
				x_keys_array(l_rec_num) := l_key_id;
				l_rec_num := l_rec_num + 1;
		     END IF;
		CLOSE Get_SymKeys_csr;
    	END LOOP;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_UserSelectedKeys;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_UserSelectedKeys;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_UserSelectedKeys;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_UserSelectedKeys;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Insert_VendorNews
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Inserts News in to the vendor news table
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id         IN  NUMBER    Required
--                    vendor id.
--                 p_news_rec        IN  AMV_NEWS_OBJ_TYPE  Required
--                    array of news objects.
--    OUT NOCOPY         : x_return_status                    OUT NOCOPY  VARCHAR2
--                 x_msg_count                        OUT NOCOPY  NUMBER
--                 x_msg_data                         OUT NOCOPY  VARCHAR2
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Insert_VendorNews
(     p_api_version     		IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_vendor_id          	IN  NUMBER,
      p_news_rec      	IN  AMV_NEWS_OBJ_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Insert_VendorNews';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id     		number := Get_SBPId;
l_login_user_id     	number := Get_SBPId;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_news_id		number;
l_key_id		varchar2(60);
l_vendor_key_id		number;
l_miss_rec		number := 0;
l_object_version_number	number := 1;

CURSOR Get_VendorKeyId_csr IS
select	vendor_key_id
from	amv_vendor_keys
where	vendor_id = p_vendor_id
and	vendor_key = l_key_id;

CURSOR NewsId_seq IS
select amv_news_s.nextval
from dual;
--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Insert_VendorNews;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    l_key_id := p_news_rec.key_id;
    OPEN Get_VendorKeyId_csr;
		FETCH Get_VendorKeyId_csr INTO l_vendor_key_id;
    CLOSE Get_VendorKeyId_csr;
    IF l_vendor_key_id is not null THEN
     BEGIN
	  OPEN NewsId_seq;
	  	FETCH NewsId_seq INTO l_news_id;
	  CLOSE NewsId_seq;

	  INSERT INTO amv_news (
		news_id,
		object_version_number,
		last_update_date,
		last_updated_by,
		creation_date,
		created_by,
		last_update_login,
		vendor_key_id,
		news_url,
		news_title,
		provider,
		date_time
	  )
	  VALUES (
		l_news_id,
		l_object_version_number,
		sysdate,
		l_user_id,
		sysdate,
		l_user_id,
		l_user_id,
		l_vendor_key_id,
		p_news_rec.news_url,
		p_news_rec.title,
		p_news_rec.provider,
		p_news_rec.date_time
	  );

     EXCEPTION
	 WHEN OTHERS THEN
	  l_miss_rec := l_miss_rec + 1;
     END;
    ELSE
	  l_miss_rec := l_miss_rec + 1;
    END IF;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Insert_VendorNews;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Insert_VendorNews;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Insert_VendorNews;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Insert_VendorNews;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Start of comments
--    API name   : Get_CompanyNews
--    Type       : Private
--    Pre-reqs   : None
--    Function   : Inserts News in to the vendor news table
--    Parameters :
--    IN           p_api_version             IN  NUMBER    Required
--                 p_init_msg_list           IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_commit                  IN  VARCHAR2  Optional
--                        Default = FND_API.G_FALSE
--                 p_validation_level        IN  NUMBER    Optional
--                        Default = FND_API.G_VALID_LEVEL_FULL
--                 p_vendor_id         IN  NUMBER    Required
--                    vendor id.
--    OUT        : x_return_status     OUT VARCHAR2
--                 x_msg_count         OUT NUMBER
--                 x_msg_data          OUT VARCHAR2
--                 x_news_array        OUT AMV_NEWS_VARRAY_TYPE
--                    array of news objects.
--    Version    : Current version     1.0
--                 Previous version    1.0
--                 Initial version     1.0
--    Notes      :
--
-- End of comments
--
PROCEDURE Get_CompanyNews
(     p_api_version     		IN  NUMBER,
      p_init_msg_list    	IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit           	IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level 	IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
      x_return_status    	OUT NOCOPY  VARCHAR2,
      x_msg_count        	OUT NOCOPY  NUMBER,
      x_msg_data         	OUT NOCOPY  VARCHAR2,
      p_stock_id          	IN  NUMBER,
      x_news_array      		OUT NOCOPY  AMV_NEWS_VARRAY_TYPE
)
IS
l_api_name          	CONSTANT VARCHAR2(30) := 'Get_CompanyNews';
l_api_version      	CONSTANT NUMBER := 1.0;
l_full_name          	CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
--
l_user_id     		number := -1;
l_login_user_id     	number := -1;
l_login_user_status 	varchar2(30);
l_Error_Msg         	varchar2(2000);
l_Error_Token         	varchar2(80);
--
l_key_id		varchar2(60);
l_news_url	varchar2(240);
l_title		varchar2(240);
l_provider	varchar2(80);
l_date_time	date;
l_rec_num 	number := 0;


CURSOR Get_News_csr IS
select	v.vendor_key
,		n.news_url
,		n.news_title
,		n.provider
,		n.date_time
from	 amv_news n
,	 amv_vendor_keys v
where v.stock_id = p_stock_id
and   v.vendor_key_id = n.vendor_key_id
order by n.date_time desc;

--
BEGIN
    -- Standard begin of API savepoint
    SAVEPOINT  Get_CompanyNews;
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call (
       l_api_version,
       p_api_version,
       l_api_name,
       G_PKG_NAME)
    THEN
       RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': Start');
       FND_MSG_PUB.Add;
    END IF;
    --Initialize message list if p_init_msg_list is TRUE.
    IF FND_API.To_Boolean (p_init_msg_list) THEN
       FND_MSG_PUB.initialize;
    END IF;
    -- Initialize API return status to sucess
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --
    OPEN Get_News_csr;
	LOOP
		l_rec_num := l_rec_num + 1;
    		FETCH Get_News_csr INTO x_news_array(l_rec_num);
		EXIT WHEN Get_News_csr%NOTFOUND;
	END LOOP;
    CLOSE Get_News_csr;
    --

    -- Success message
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_SUCCESS)
    THEN
       FND_MESSAGE.Set_Name('AMV', 'AMV_API_SUCCESS_MESSAGE');
       FND_MESSAGE.Set_Token('ROW', l_full_name);
       FND_MSG_PUB.Add;
    END IF;
    --Standard check of commit
    IF FND_API.To_Boolean ( p_commit ) THEN
        COMMIT WORK;
    END IF;
    -- Debug Message
    IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
       FND_MESSAGE.Set_Name('AMV','AMV_API_DEBUG_MESSAGE');
       FND_MESSAGE.Set_Token('ROW',l_full_name||': End');
       FND_MSG_PUB.Add;
    END IF;
    --Standard call to get message count and if count=1, get the message
    FND_MSG_PUB.Count_And_Get (
       p_encoded => FND_API.G_FALSE,
       p_count => x_msg_count,
       p_data  => x_msg_data
       );
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
       ROLLBACK TO  Get_CompanyNews;
       x_return_status := FND_API.G_RET_STS_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       ROLLBACK TO  Get_CompanyNews;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
   WHEN OTHERS THEN
       ROLLBACK TO  Get_CompanyNews;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
	IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
        	FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
        END IF;
       -- Standard call to get message count and if count=1, get the message
       FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
          );
--
END Get_CompanyNews;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
END amv_stock_pvt;

/
