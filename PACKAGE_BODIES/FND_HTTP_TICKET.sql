--------------------------------------------------------
--  DDL for Package Body FND_HTTP_TICKET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_HTTP_TICKET" as
/* $Header: AFSTCKTB.pls 120.1 2005/07/02 04:18:30 appldev noship $ */
--
  C_SECS_PER_DAY constant number       := 24*60*60;
--
  function CREATE_TICKET(P_OPERATION in varchar2 default null,
                         P_ARGUMENT  in varchar2 default null,
                         P_LIFESPAN  in number   default 60)
    return raw
  is
  pragma AUTONOMOUS_TRANSACTION;
    X_TICKET     raw(16);
    X_START_DATE date;
    X_END_DATE   date := null;
    X_END_DAY    number;
    X_END_SEC    number;
    X_END_STR    varchar2(30);
    X_LIFE_DAYS  number;
  begin
    for I in 1..3 loop
      X_TICKET := FND_CRYPTO.RANDOMBYTES(16);
      begin
        X_START_DATE := SYSDATE;
        if (P_LIFESPAN is not null) then
          X_END_DAY := to_number(to_char(X_START_DATE,'J'));
          X_END_SEC := to_number(to_char(X_START_DATE,'SSSSS')) + P_LIFESPAN;
          if (X_END_SEC >= C_SECS_PER_DAY) then
            X_LIFE_DAYS := floor(X_END_SEC/C_SECS_PER_DAY);
            X_END_SEC := X_END_SEC - (X_LIFE_DAYS * C_SECS_PER_DAY);
            X_END_DAY := X_END_DAY + X_LIFE_DAYS;
          end if;
          X_END_STR := to_char(to_date(to_char(X_END_DAY),'J'),'YYYY/MM/DD')||
                       ' '||to_char(to_date(to_char(X_END_SEC), 'SSSSS'),
                                    'HH24:MI:SS');
          X_END_DATE := to_date(X_END_STR,'YYYY/MM/DD HH24:MI:SS');
        end if;
        insert into FND_HTTP_TICKETS (TICKET, OPERATION, ARGUMENT,
                                      START_DATE, END_DATE)
             values (X_TICKET, P_OPERATION, P_ARGUMENT,
                     X_START_DATE, X_END_DATE);
        commit;
        return(X_TICKET);
      exception
      when DUP_VAL_ON_INDEX then
        null; -- retry up to three times before failing
      when OTHERS then
        exit; -- some other failure, exit the loop now
      end;
    end loop;
    rollback;
    return(null);
  end CREATE_TICKET;
--
  function CREATE_TICKET_STRING(P_OPERATION in varchar2 default null,
                                P_ARGUMENT  in varchar2 default null,
                                P_LIFESPAN  in number   default 60)
    return varchar2
  is
  begin
    return(FND_CRYPTO.ENCODE(CREATE_TICKET(P_OPERATION,
                                           P_ARGUMENT,
                                           P_LIFESPAN),
                             FND_CRYPTO.ENCODE_URL));
  end CREATE_TICKET_STRING;
--
  function SET_SERVICE_TICKET(P_SERVICE in varchar2) return raw
  is
  pragma AUTONOMOUS_TRANSACTION;
    X_TICKET     raw(16);
    X_OLD_TICKET raw(16);
    X_END_DATE   date;
  begin
    select TICKET, OLD_TICKET, END_DATE
      into X_TICKET, X_OLD_TICKET, X_END_DATE
      from FND_HTTP_SERVICE_TICKETS
     where SERVICE = P_SERVICE
       for update;
    if (X_END_DATE <= SYSDATE) then
      X_OLD_TICKET := X_TICKET;
      X_TICKET := FND_CRYPTO.RANDOMBYTES(16);
      update FND_HTTP_SERVICE_TICKETS
         set TICKET = X_TICKET,
             OLD_TICKET = X_OLD_TICKET,
             END_DATE = SYSDATE + 1
       where SERVICE = P_SERVICE;
      commit;
    else
      rollback;
    end if;
    return(UTL_RAW.CONCAT(X_TICKET, X_OLD_TICKET));
  exception when OTHERS then
    rollback;
    return(null);
  end SET_SERVICE_TICKET;
--
  function GET_SERVICE_TICKET(P_SERVICE in varchar2)
    return raw
  is
    X_TICKET     raw(16);
    X_OLD_TICKET raw(16);
    X_END_DATE   date;
  begin
    select TICKET, OLD_TICKET, END_DATE
      into X_TICKET, X_OLD_TICKET, X_END_DATE
      from FND_HTTP_SERVICE_TICKETS where SERVICE = P_SERVICE;
    if (X_END_DATE <= SYSDATE) then
      return(SET_SERVICE_TICKET(P_SERVICE));
    end if;
    return(UTL_RAW.CONCAT(X_TICKET, X_OLD_TICKET));
  exception when OTHERS then
    return(null);
  end GET_SERVICE_TICKET;
--
  function GET_SERVICE_TICKET_STRING(P_SERVICE in varchar2)
    return varchar2
  is
    X_TICKETS raw(32);
  begin
    X_TICKETS := GET_SERVICE_TICKET(P_SERVICE);
    return(FND_CRYPTO.ENCODE(UTL_RAW.SUBSTR(X_TICKETS,1,16),
                             FND_CRYPTO.ENCODE_URL)||
           FND_CRYPTO.ENCODE(UTL_RAW.SUBSTR(X_TICKETS,17,16),
                             FND_CRYPTO.ENCODE_URL));
  end GET_SERVICE_TICKET_STRING;
--
  function COMPARE_SERVICE_TICKETS(P_TICKET1 in raw, P_TICKET2 in raw)
    return boolean
  is
    X_TICKET11   raw(16);
    X_TICKET12   raw(16);
    X_TICKET21   raw(16);
    X_TICKET22   raw(16);
  begin
    if ((P_TICKET1 is null) or (P_TICKET2 is null)) then
      return(false);
    end if;
    X_TICKET11 := UTL_RAW.SUBSTR(P_TICKET1,1,16);
    X_TICKET12 := UTL_RAW.SUBSTR(P_TICKET1,17,16);
    X_TICKET21 := UTL_RAW.SUBSTR(P_TICKET2,1,16);
    X_TICKET22 := UTL_RAW.SUBSTR(P_TICKET2,17,16);
    return((X_TICKET11 = X_TICKET21) or (X_TICKET12 = X_TICKET21) or
           (X_TICKET11 = X_TICKET22) or (X_TICKET12 = X_TICKET22));
  end COMPARE_SERVICE_TICKETS;
--
  function COMPARE_SERVICE_TICKET_STRINGS(P_TICKET1 in varchar2,
                                          P_TICKET2 in varchar2)
    return boolean
  is
    N1           number;
    N2           number;
    X_TICKET11   varchar2(256);
    X_TICKET12   varchar2(256);
    X_TICKET21   varchar2(256);
    X_TICKET22   varchar2(256);
  begin
    if ((P_TICKET1 is null) or (P_TICKET2 is null)) then
      return(false);
    end if;
    N1 := length(P_TICKET1)/2;
    N2 := length(P_TICKET2)/2;
    if (N1 <> N2) then
      return(false);
    end if;
    X_TICKET11 := substr(P_TICKET1,1,N1);
    X_TICKET12 := substr(P_TICKET1,1+N1,N1);
    X_TICKET21 := substr(P_TICKET2,1,N2);
    X_TICKET22 := substr(P_TICKET2,1+N2,N2);
    return((X_TICKET11 = X_TICKET21) or (X_TICKET12 = X_TICKET21) or
           (X_TICKET11 = X_TICKET22) or (X_TICKET12 = X_TICKET22));
  end COMPARE_SERVICE_TICKET_STRINGS;
--
  function CHECK_TICKET(P_TICKET    in  raw,
                        P_OPERATION out nocopy varchar2,
                        P_ARGUMENT  out nocopy varchar2)
    return boolean
  is
    X_END_DATE date;
  begin
    select OPERATION, ARGUMENT, END_DATE
      into P_OPERATION, P_ARGUMENT, X_END_DATE
      from FND_HTTP_TICKETS
     where TICKET = P_TICKET;
    if (X_END_DATE is not null) then
      if (X_END_DATE < SYSDATE) then
        return(false);
      end if;
    end if;
    return(true);
  exception when OTHERS then
    return(null);
  end CHECK_TICKET;
--
  function CHECK_TICKET(P_TICKET in raw) return boolean
  is
    X_OPERATION varchar2(255);
    X_ARGUMENT  varchar2(4000);
  begin
    return(CHECK_TICKET(P_TICKET, X_OPERATION, X_ARGUMENT));
  end CHECK_TICKET;
--
  function CHECK_TICKET_STRING(P_TICKET    in  varchar2,
                               P_OPERATION out nocopy varchar2,
                               P_ARGUMENT  out nocopy varchar2)
    return boolean
  is
  begin
    return(CHECK_TICKET(FND_CRYPTO.DECODE(P_TICKET, FND_CRYPTO.ENCODE_URL),
                        P_OPERATION, P_ARGUMENT));
  end CHECK_TICKET_STRING;
--
  function CHECK_TICKET_STRING(P_TICKET in varchar2) return boolean
  is
  begin
    return(CHECK_TICKET(FND_CRYPTO.DECODE(P_TICKET, FND_CRYPTO.ENCODE_URL)));
  end CHECK_TICKET_STRING;
--
  function UPDATE_TICKET(P_TICKET    in raw,
                         P_OPERATION in varchar2,
                         P_ARGUMENT  in varchar2)
    return boolean
  is
  pragma AUTONOMOUS_TRANSACTION;
    X_END_DATE date;
  begin
    update FND_HTTP_TICKETS
       set OPERATION = P_OPERATION,
           ARGUMENT = P_ARGUMENT
     where TICKET = P_TICKET
    returning END_DATE into X_END_DATE;
    if (X_END_DATE is not null) then
      if (X_END_DATE < SYSDATE) then
        rollback;
        return(false);
      end if;
    end if;
    commit;
    return(true);
  exception when OTHERS then
    rollback;
    return(null);
  end UPDATE_TICKET;
--
  function UPDATE_TICKET_STRING(P_TICKET    in varchar2,
                                P_OPERATION in varchar2,
                                P_ARGUMENT  in varchar2)
    return boolean
  is
  begin
    return(UPDATE_TICKET(FND_CRYPTO.DECODE(P_TICKET, FND_CRYPTO.ENCODE_URL),
                         P_OPERATION, P_ARGUMENT));
  end UPDATE_TICKET_STRING;
--
  function CHECK_ONETIME_TICKET(P_TICKET    in  raw,
                                P_OPERATION out nocopy varchar2,
                                P_ARGUMENT  out nocopy varchar2)
    return boolean
  is
  pragma AUTONOMOUS_TRANSACTION;
    X_END_DATE date;
    X_TICKET   raw(16);
  begin
    delete from FND_HTTP_TICKETS
          where TICKET = P_TICKET
      returning TICKET, OPERATION, ARGUMENT, END_DATE
           into X_TICKET, P_OPERATION, P_ARGUMENT, X_END_DATE;
    commit;
    if (X_TICKET is null) then
      return(null);  -- matching ticket was not found
    end if;
    if (X_END_DATE is not null) then
      if (X_END_DATE < SYSDATE) then
        return(false);
      end if;
    end if;
    return(true);
  exception when OTHERS then
    rollback;
    return(null);
  end CHECK_ONETIME_TICKET;
--
  function CHECK_ONETIME_TICKET_STRING(P_TICKET    in  varchar2,
                                       P_OPERATION out nocopy varchar2,
                                       P_ARGUMENT  out nocopy varchar2)
    return boolean
  is
  begin
    return(CHECK_ONETIME_TICKET(FND_CRYPTO.DECODE(P_TICKET,
                                                  FND_CRYPTO.ENCODE_URL),
                                P_OPERATION, P_ARGUMENT));
  end CHECK_ONETIME_TICKET_STRING;
--
  procedure DESTROY_TICKET(P_TICKET in raw)
  is
  pragma AUTONOMOUS_TRANSACTION;
  begin
    delete from FND_HTTP_TICKETS where TICKET = P_TICKET;
    commit;
  exception when OTHERS then
    rollback; -- ignore failures
  end DESTROY_TICKET;
--
  procedure DESTROY_TICKET_STRING(P_TICKET in varchar2)
  is
  begin
    DESTROY_TICKET(FND_CRYPTO.DECODE(P_TICKET, FND_CRYPTO.ENCODE_URL));
  end DESTROY_TICKET_STRING;
--
  procedure PURGE_TICKETS(P_MAX_LIFESPAN in number default null)
  is
  pragma AUTONOMOUS_TRANSACTION;
  begin
    if (P_MAX_LIFESPAN is not null) then
      delete from FND_HTTP_TICKETS
       where SYSDATE > END_DATE
          or (SYSDATE - START_DATE) > (P_MAX_LIFESPAN/C_SECS_PER_DAY);
    else
      delete from FND_HTTP_TICKETS where SYSDATE > END_DATE;
    end if;
    commit;
  exception when OTHERS then
    rollback; -- ignore failures
  end PURGE_TICKETS;
--
end FND_HTTP_TICKET;

/
