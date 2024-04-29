--------------------------------------------------------
--  DDL for Package Body IEX_CASE_INFO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IEX_CASE_INFO_PUB" AS
/* $Header: iexcsinb.pls 120.3 2004/12/15 15:07:30 jsanju ship $ */

  ---------------------------------------------------------------------
  -- PROCEDURE get_total_rcvble_for_case
  ---------------------------------------------------------------------
PG_DEBUG NUMBER ;


  FUNCTION get_Amount_Overdue (p_case_id IN NUMBER) return NUMBER

  IS
    l_Amount_Overdue   NUMBER := 0;
    l_total_overdue    NUMBER := 0;
    l_contract_id      NUMBER;
    l_return_status    VARCHAR2(5);
    j                  NUMBER := 0;

    Type refCur is Ref Cursor;
    object_cur refCur;
    vPLSQL varchar2(500);

  BEGIN

   if PG_DEBUG < 10 then
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage('IEX_CASE_INFO_PUB.get_amount_overdue Start');
     END IF;
   end if;

   vPLSQL := 'SELECT OBJECT_ID ' ||
             'FROM IEX_CASE_OBJECTS ' ||
             ' WHERE CAS_ID = ' || to_char(p_case_id) ||
             ' AND OBJECT_CODE = ''CONTRACTS''' ||
             ' AND ACTIVE_FLAG = ''Y''';
    open object_cur for vPLSQL;
    LOOP
        j := j + 1;
        fetch object_cur into l_contract_id;
    exit when object_cur%NOTFOUND;
        l_Amount_Overdue := 0;
        l_return_status := OKL_CONTRACT_INFO.get_amount_past_due(l_contract_id, l_Amount_Overdue);
        l_total_overdue := l_total_overdue + nvl(l_Amount_Overdue,0);

    end loop;
    close object_cur;

   if PG_DEBUG < 10 then
     IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
     IEX_DEBUG_PUB.LogMessage('Found ' || j || ' objects for case ' || p_case_id);
     IEX_DEBUG_PUB.LogMessage('IEX_CASE_INFO_PUB.get_amount_overdue END');
     END IF;
   end if;

   return nvl(l_total_overdue,0);

  END;

  PROCEDURE get_total_rcvble_for_case (
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_api_name          VARCHAR2(30);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_api_version       NUMBER ;
    l_total_amt         NUMBER ;
    l_rcvble_amt        NUMBER ;

    CURSOR c_case(l_case_id NUMBER) IS
    SELECT OBJECT_ID
      FROM IEX_CASE_OBJECTS
     WHERE CAS_ID = l_case_id
       AND OBJECT_CODE = 'CONTRACTS'
       AND ACTIVE_FLAG = 'Y';

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_api_version        := 2.0;
    l_total_amt          := 0;
    l_rcvble_amt         := 0;
    l_api_name   := 'get_total_rcvble_for_case';
  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
    END IF;
  end if;

  OPEN C_CASE(p_case_id);
  LOOP
    FETCH C_CASE INTO l_contract_id;
    EXIT WHEN NOT C_CASE%FOUND;

   BEGIN
    l_rcvble_amt := 0;
    x_return_status := OKL_CONTRACT_INFO.get_outstanding_rcvble(l_contract_id, l_rcvble_amt);
   exception when others then
   null;
  end;

    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('ContractID: ' || l_contract_id || ' Recvble Amt: ' || l_rcvble_amt);
      END IF;
    end if;

    l_total_amt := l_total_amt + nvl(l_rcvble_amt,0);

  END LOOP;
  CLOSE C_CASE;

  x_total_amt := NVL(l_total_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('Total Case Overdue Amount $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;

  END get_total_rcvble_for_case;




  FUNCTION get_total_rcvble_for_case_fn (p_case_id IN NUMBER) return NUMBER
  IS
	l_amount		Number ;
	l_return_status	varchar2(300) ;
  Begin
	get_total_rcvble_for_case(p_case_id, l_amount, l_return_status) ;
	return l_amount ;
  EXCEPTION
  	WHEN OTHERS then
      	IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      	IEX_DEBUG_PUB.LogMessage('Exec Error - get_total_rcvble_for_case_fn ' || SQLCODE || sqlerrm);
      	END IF;
  End ;


  ---------------------------------------------------------------------
  -- PROCEDURE get total net book value for a case
  ---------------------------------------------------------------------
  PROCEDURE get_total_net_book_value (
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_api_version       NUMBER ;
    l_api_name          VARCHAR2(30);
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_total_amt         NUMBER(15,2);
    l_nbook_amt         NUMBER ;

    CURSOR c_case(l_case_id NUMBER) IS
    SELECT OBJECT_ID
      FROM IEX_CASE_OBJECTS
     WHERE CAS_ID = l_case_id
       AND OBJECT_CODE = 'CONTRACTS'
       AND ACTIVE_FLAG = 'Y';

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_total_amt         := 0;
    l_api_name   := 'get_total_net_book_value';
    l_api_version      := 2.0;
    l_nbook_amt         := 0;
  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
    END IF;
  end if;

  OPEN C_CASE(p_case_id);
  LOOP
    FETCH C_CASE INTO l_contract_id;
    EXIT WHEN NOT C_CASE%FOUND;

    l_nbook_amt := 0;
    x_return_status := OKL_CONTRACT_INFO.get_net_book_value(l_contract_id, l_nbook_amt);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('ContractID: ' || l_contract_id || ' Net Book: ' || l_nbook_amt);
      END IF;
    end if;

    IF (x_return_status = fnd_api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
    ELSIF (x_return_status = fnd_api.G_RET_STS_ERROR) THEN
        RAISE fnd_api.G_EXC_ERROR;
    END IF;
    l_total_amt := l_total_amt + l_nbook_amt;

  END LOOP;
  CLOSE C_CASE;

  x_total_amt := NVL(l_total_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('--------->Total Case Net Book Amount $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;

  END get_total_net_book_value;

  ---------------------------------------------------------------------
  -- PROCEDURE get total contract Original Equipment Cost for a case
  ---------------------------------------------------------------------
  PROCEDURE get_contract_oec (
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_total_amt         NUMBER ;
    l_oec_amt           NUMBER ;
    l_api_version       NUMBER ;
    l_api_name          VARCHAR2(30);

    CURSOR c_case(l_case_id NUMBER) IS
    SELECT OBJECT_ID
      FROM IEX_CASE_OBJECTS
     WHERE CAS_ID = l_case_id
       AND OBJECT_CODE = 'CONTRACTS'
       AND ACTIVE_FLAG = 'Y';

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_total_amt         := 0;
    l_oec_amt           := 0;
    l_api_version       := 2.0;
    l_api_name          := 'get_contract_oec';

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
    END IF;
  end if;

  OPEN C_CASE(p_case_id);
  LOOP
    FETCH C_CASE INTO l_contract_id;
    EXIT WHEN NOT C_CASE%FOUND;

    --jsanju comment for bug #-2605083
    -- raverma 04252003 uncomment for bug#2924455
    --( l_oec_amt is intialized to zero)
    l_oec_amt := 0;
    l_oec_amt := OKL_SEEDED_FUNCTIONS_PVT.contract_oec(p_chr_id  => l_contract_id,
                                                       p_line_id => null);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('ContractID: ' || l_contract_id || ' OEC Amt: ' || l_oec_amt);
      END IF;
    end if;

    l_total_amt := l_total_amt + l_oec_amt;

  END LOOP;
  CLOSE C_CASE;

  x_total_amt := NVL(l_total_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('Total Contract oec $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;

  END get_contract_oec;

  ---------------------------------------------------------------------
  -- PROCEDURE get_contract_tradein
  ---------------------------------------------------------------------
  PROCEDURE get_contract_tradein(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_total_amt         NUMBER;
    l_tradein_amt       NUMBER;
    l_api_version       NUMBER;
    l_api_name          VARCHAR2(30);

    CURSOR c_case(l_case_id NUMBER) IS
    SELECT OBJECT_ID
      FROM IEX_CASE_OBJECTS
     WHERE CAS_ID = l_case_id
       AND OBJECT_CODE = 'CONTRACTS'
       AND ACTIVE_FLAG = 'Y';

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_total_amt         := 0;
    l_tradein_amt       := 0;
    l_api_version       := 2.0;
    l_api_name          := 'get_contract_tradein';
  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
    END IF;
  end if;

  OPEN C_CASE(p_case_id);
  LOOP
    FETCH C_CASE INTO l_contract_id;
    EXIT WHEN NOT C_CASE%FOUND;


    /* -jsanju comment for bug #-2605083
     ( l_tradein_amt is intialized to zero)
    */
    -- raverma 04252003 uncomment #2924455
    l_tradein_amt := 0;

    l_tradein_amt := OKL_SEEDED_FUNCTIONS_PVT.contract_tradein(p_chr_id  => l_contract_id,
                                                               p_line_id => null);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('ContractID: ' || l_contract_id || ' TradeinAmt: ' || l_tradein_amt);
      END IF;
    end if;

    l_total_amt := l_total_amt + l_tradein_amt;

  END LOOP;
  CLOSE C_CASE;

  x_total_amt := NVL(l_total_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( debug_msg => 'Total Contract Tradein $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;

  END get_contract_tradein;

  ---------------------------------------------------------------------
  -- PROCEDURE get_contract_capital_reduction
  ---------------------------------------------------------------------
  PROCEDURE get_contract_capital_reduction(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_total_amt         NUMBER;
    l_capred_amt        NUMBER;
    l_api_version       NUMBER;
    l_api_name          VARCHAR2(30);

    CURSOR c_case(l_case_id NUMBER) IS
    SELECT OBJECT_ID
      FROM IEX_CASE_OBJECTS
     WHERE CAS_ID = l_case_id
       AND OBJECT_CODE = 'CONTRACTS'
       AND ACTIVE_FLAG = 'Y';

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_total_amt        := 0;
    l_capred_amt       := 0;
    l_api_version      := 2.0;
    l_api_name         := 'get_contract_capital_reduction';
  IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
  IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
  END IF;

  OPEN C_CASE(p_case_id);
  LOOP
    FETCH C_CASE INTO l_contract_id;
    EXIT WHEN NOT C_CASE%FOUND;

    -- -jsanju comment for bug #-2605083
    -- ( l_capred_amt is intialized to zero)
    -- raverma 04252003 uncomment #2924455

     l_capred_amt := 0;
     l_capred_amt := OKL_SEEDED_FUNCTIONS_PVT.contract_capital_reduction(p_chr_id  => l_contract_id,
                                                                         p_line_id => null);
     if PG_DEBUG < 10 then
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('ContractID: ' || l_contract_id || ' CapRed_Amt: ' || l_capred_amt);
       END IF;
     end if;

     l_total_amt := l_total_amt + l_capred_amt;

  END LOOP;
  CLOSE C_CASE;

  x_total_amt := NVL(l_total_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('Total Capital Reduction $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;
  END get_contract_capital_reduction;

  ---------------------------------------------------------------------
  -- PROCEDURE get_contract_fees_capitalized
  ---------------------------------------------------------------------
  PROCEDURE get_contract_fees_capitalized(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_total_amt         NUMBER;
    l_feecap_amt        NUMBER;
    l_api_version       NUMBER;
    l_api_name          VARCHAR2(30);

    CURSOR c_case(l_case_id NUMBER) IS
    SELECT OBJECT_ID
      FROM IEX_CASE_OBJECTS
     WHERE CAS_ID = l_case_id
       AND OBJECT_CODE = 'CONTRACTS'
       AND ACTIVE_FLAG = 'Y';

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_total_amt        := 0;
    l_feecap_amt       := 0;
    l_api_version      := 2.0;
    l_api_name         := 'get_contract_fees_capitalized';
  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
    END IF;
  end if;

  OPEN C_CASE(p_case_id);
  LOOP
    FETCH C_CASE INTO l_contract_id;
    EXIT WHEN NOT C_CASE%FOUND;

    -- -jsanju comment for bug #-2605083
    -- ( l_feecap_amt is intialized to zero)
    -- raverma 04252003 uncomment #2924455

    l_feecap_amt := 0;
    l_feecap_amt := OKL_SEEDED_FUNCTIONS_PVT.contract_fees_capitalized(p_chr_id  => l_contract_id,
                                                                       p_line_id => null);
    if PG_DEBUG < 10 then
       IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
       IEX_DEBUG_PUB.LogMessage('ContractID: ' || l_contract_id || ' FeeCap_Amt: ' || l_feecap_amt);
       END IF;
    end if;

    l_total_amt := l_total_amt + l_feecap_amt;

  END LOOP;
  CLOSE C_CASE;

  x_total_amt := NVL(l_total_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage( debug_msg => 'Contract Fees Capitalized $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;
  END get_contract_fees_capitalized;


  ---------------------------------------------------------------------
  -- PROCEDURE get_total_capital_amount
  ---------------------------------------------------------------------
  PROCEDURE get_total_capital_amount(
     p_case_id       IN NUMBER,
     x_total_amt     OUT NOCOPY NUMBER,
     x_return_status OUT NOCOPY VARCHAR2)
  IS
    l_msg_count         NUMBER;
    l_msg_data          VARCHAR2(2000);
    l_contract_id       NUMBER;

    l_total_cap_amt     NUMBER;
    l_oec_amt           NUMBER;
    l_total_oec_amt     NUMBER;
    l_trade_amt         NUMBER;
    l_total_trade_amt   NUMBER;
    l_capred_amt        NUMBER;
    l_total_capred_amt  NUMBER;
    l_feecap_amt        NUMBER;
    l_total_feecap_amt  NUMBER;
    l_api_version       NUMBER;
    l_api_name          VARCHAR2(30);

CURSOR c_case_id (l_case_id NUMBER) IS
select nvl(sum(okl.oec) ,0)
from okc_k_lines_v okc
    ,okl_k_lines okl
    ,okc_line_styles_v lse
    ,iex_case_objects icas
where okc.id=okl.id
and  okc.lse_id = lse.id
and lse.lty_code='FREE_FORM1'
and okc.chr_id =icas.object_id
and icas.cas_id =p_case_id;

  BEGIN

  -- Initialize API return status to SUCCESS
  x_return_status := FND_API.G_RET_STS_SUCCESS;

    l_total_cap_amt    := 0;
    l_oec_amt          := 0;
    l_total_oec_amt    := 0;
    l_trade_amt        := 0;
    l_total_trade_amt  := 0;
    l_capred_amt       := 0;
    l_total_capred_amt := 0;
    l_feecap_amt       := 0;
    l_total_feecap_amt := 0;
    l_api_version      := 2.0;
    l_api_name         := 'get_total_capital_amount';
  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('PUB:'||G_PKG_NAME||'.'||l_api_name||' Start');
    END IF;
  end if;
  OPEN c_Case_id (p_case_id);
  FETCH c_Case_id INTO l_total_cap_amt ;
  CLOSE c_Case_id;

  x_total_amt := NVL(l_total_cap_amt, 0);

  if PG_DEBUG < 10 then
    IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
    IEX_DEBUG_PUB.LogMessage('Total Capital Amount $'||x_total_amt);
    END IF;
  end if;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Exec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Unexec Error ' || sqlerrm);
      END IF;
    end if;

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
    END IF;
    FND_MSG_PUB.Count_And_Get(p_count => l_msg_count, p_data => l_msg_data);
    if PG_DEBUG < 10 then
      IF (FND_LOG.LEVEL_EVENT >= PG_DEBUG) THEN
      IEX_DEBUG_PUB.LogMessage('Other Error ' || sqlerrm);
      END IF;
    end if;
  END get_total_capital_amount;

BEGIN

PG_DEBUG := FND_LOG.G_CURRENT_RUNTIME_LEVEL;


END IEX_CASE_INFO_PUB;

/
