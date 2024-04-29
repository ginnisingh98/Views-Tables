--------------------------------------------------------
--  DDL for Package Body WF_CACHE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WF_CACHE" as
 /* $Header: WFCACHEB.pls 120.2 2006/02/22 16:40:17 rwunderl ship $ */


/*======================================+
 |                                      |
 | Global Private Cache Variables       |
 |                                      |
 +======================================+================================*/

 HashBase               NUMBER := 1;
 HashSize               NUMBER := 16777216;  -- 2^24
 HashCollision          EXCEPTION;
 CacheSessionID         DATE;

 TrustedTransaction     BOOLEAN;

/*======================================+
 |                                      |
 | Functions                            |
 |                                      |
 +======================================+================================*/


/*===========================+
 | SetHashRange              |
 +===========================+===================+
 | IN:      p_HashBase in NUMBER,                |
 |          p_HashSize in NUMBER                 |
 +===============================================*/

  PROCEDURE SetHashRange ( p_HashBase in  NUMBER,
                           p_HashSize in  NUMBER ) is


    BEGIN
      WF_CACHE.Clear;
      HashBase := p_HashBase;
      HashSize := p_HashSize;

    END;


/*===========================+
 | HashKey                   |
 +===========================+===================+
 | IN:      p_HashString in VARCHAR2             |
 +-----------------------------------------------+
 | RETURNS: number                               |
 +-----------------------------------------------+
 | NOTES: We use HashBase and HashSize to prevent|
 |        a caller from setting the hash base or |
 |        size after caching has begun.          |
 +===============================================*/

  FUNCTION HashKey (p_HashString in varchar2) return number is

   l_hashKey        number;

   BEGIN

       return(dbms_utility.get_hash_value(p_HashString, HashBase,
                                                HashSize));

   END;



/*=====================================+
 |                                     |
 | Maintenance Procedures              |
 |                                     |
 +=====================================+================================+
 | Maintenance procedures perform administrative functions such as      |
 | clearing the cache, managing cache positions, and raising errors.    |
 |                                                                      |
 +======================================================================*/

--<rwunderl:2412940>
/*===========================+
 | ClearSynch                |
 +===============================================*/

   PROCEDURE ClearSynch is

   BEGIN

     /*===============================+
     | Clear the cache tables that    |
     | are used for #SYNCH mode       |
     +================================*/
     ItemAttrValues.DELETE;

   END;

/*===========================+
 | Clear                     |
 +===============================================*/

  PROCEDURE Clear is

   BEGIN

   /*================================+
    |Clear the Cache Tables.         |
    +================================*/
    Activities.DELETE;
    ActivityAttributes.DELETE;
    ActivityAttrValues.DELETE;
    ActivityTransitions.DELETE;
    ItemAttributes.DELETE;
    ItemTypes.DELETE;
    ProcessActivities.DELETE;
    NLSParameters.DELETE;

   END;


/*===========================+
 | CacheManager              |
 +===========================+===================+
 | IN: p_TableName    (PLS_INTEGER)              |
 |                                               |
 +===============================================*/

   PROCEDURE CacheManager (TableName in  PLS_INTEGER,
                           NumRows   in  NUMBER)  is

     BEGIN
       if (TableName = WF_CACHE.TAB_Activities) then
         if (Activities.COUNT + NumRows >= MaxActivities) then
           Activities.DELETE;

         end if;


       elsif (TableName = WF_CACHE.TAB_ActivityTransitions) then
         if (ActivityTransitions.COUNT + NumRows >= MaxActivityTransitions) then
           ActivityTransitions.DELETE;

         end if;


       elsif (TableName = WF_CACHE.TAB_ActivityAttributes) then
         if (ActivityAttributes.COUNT + NumRows >= MaxActivityAttrs) then
           ActivityAttributes.DELETE;

         end if;

         if (Activities.COUNT + NumRows = MaxActivities) then
           Activities.DELETE;

         end if;

         if (ProcessActivities.COUNT + NumRows >= MaxProcessActivities) then
           ProcessActivities.DELETE;

         end if;

       elsif (TableName = WF_CACHE.TAB_ActivityAttrValues) then
         if (ActivityAttrValues.COUNT + NumRows >= MaxActivityAttrValues) then
           ActivityAttrValues.DELETE;

         end if;

       elsif (TableName = WF_CACHE.TAB_ItemAttributes) then
         if (ItemAttributes.COUNT + NumRows >= MaxItemAttributes) then
           ItemAttributes.DELETE;

         end if;

       elsif (TableName = WF_CACHE.TAB_ItemTypes) then
         if (ItemTypes.COUNT + NumRows >= MaxItemTypes) then
           ItemTypes.DELETE;

         end if;

       elsif (TableName = WF_CACHE.TAB_ProcessActivities) then
         if (ProcessActivities.COUNT + NumRows >= MaxProcessActivities) then
           ProcessActivities.DELETE;

         end if;
--<rwunderl:2412971>
       elsif (TableName = WF_CACHE.TAB_ProcessStartActivities) then
         if (ProcessStartActivities.COUNT + NumRows >=
             MaxProcessStartActivities) then
           ProcessStartActivities.DELETE;

         end if;

--</rwunderl:2412971>
       else
         return;

       end if;

     END;



/*===========================+
 | MetaRefeshed              |
 +===========================+===================+
 | Returns                                       |
 |   BOOLEAN                                     |
 +-----------------------------------------------+
 |  This api checks to see if the p_itemType     |
 |  has been updated by wfload.                  |
 +===============================================*/

   FUNCTION MetaRefreshed return BOOLEAN is

   l_UpdateTime          DATE;

   BEGIN

     if( WF_CACHE.CacheSessionID is NOT NULL ) then

       /*----------------------------------------+
        | Checking to see when the itemType was  |
        | last updated.                          |
        +----------------------------------------*/
       begin
         select to_date(text, WF_ENGINE.date_format) into l_UpdateTime
         from   WF_RESOURCES
         where  TYPE='WFTKN'
         and    NAME = 'WFCACHE_META_UPD'
         and    LANGUAGE = 'US';

       exception
         when NO_DATA_FOUND then
           WF_CACHE.Reset;
           return TRUE;

         when others then
           raise;

       end;

       if ( l_UpdateTime > CacheSessionID ) then

         /*---------------------------------------+
          | The itemType was updated.  We will    |
          | Clear the cache and reset our         |
          | CacheSessionID for a new Caching      |
          | session                               |
          +---------------------------------------*/
         WF_CACHE.Clear;
         WF_CACHE.CacheSessionID := sysdate;
         return TRUE;

       end if;

     elsif (CacheSessionID is NULL) then

       /*---------------------------------------+
        | This is the first initialization of   |
        | the cache for this DB session.        |
        | Setting the CacheSessionID to sysdate |
        | and Clearing the cache.               |
        +---------------------------------------*/
       WF_CACHE.CacheSessionID := sysdate;
       WF_CACHE.Clear;
       return TRUE;

     end if;

     return FALSE;

   END;



/*===========================+
 | Reset                     |
 +===========================+===================+
 | This api will update the WFCACHE_META_UPD     |
 | resource token to the current sysdate to      |
 | cause any running caches to be cleared.  This |
 | code is called by WF_LOAD when an upload event|
 | has taken place.                              |
 +===============================================*/

   PROCEDURE Reset IS

     BEGIN
       if ((NOT trustedTransaction) or (trustedTransaction is NULL)) then
           -- We will update the token to the current sysdate.
           update WF_RESOURCES set text = to_char(sysdate,
                                                  WF_ENGINE.date_format)
           where  name = 'WFCACHE_META_UPD';

           if (sql%notfound) then
           -- When WF_CACHE.Reset is called for the very first time on a system
           -- we will jump into this code to insert the record.
             begin
              insert into WF_RESOURCES (TYPE, NAME, LANGUAGE,SOURCE_LANG, ID,
                                        TEXT, PROTECT_LEVEL, CUSTOM_LEVEL)
                    values ('WFTKN', 'WFCACHE_META_UPD', 'US', 'US', 0,
                            to_char(sysdate, WF_ENGINE.date_format), 0, 0);
             exception
               when DUP_VAL_ON_INDEX then
                 -- there is a race condition where it can potentially
                 -- have several insert at once the first time this is called.
                 null;
             end;
           end if;
        end if;
        WF_CACHE.Clear;

     END;




/*=====================================+
 |                                     |
 | Accessor Procedures                 |
 |                                     |
 +=====================================+================================+
 | Accessor procedures are the apis that consumers use to access meta-  |
 | data from cache.  Each api will require as parameters the necessary  |
 | information to locate the record in cache as well as a record index. |
 |                                                                      |
 +======================================================================*/


/*===========================+
 | GetActivity               |
 +===========================+===================+
 | IN:   itemType     (VARCHAR2)                 |
 |       name         (VARCHAR2)                 |
 |       actdate      (DATE)                     |
 +-----------------------------------------------+
 | OUT:  status     (PLS_INTEGER)                |
 |       waIND      (NUMBER)                     |
 +===============================================*/

   PROCEDURE GetActivity ( itemType in             VARCHAR2,
                           name     in             VARCHAR2,
                           actdate  in             DATE,
                           status   out    NOCOPY  PLS_INTEGER,
                           waIND    out    NOCOPY  NUMBER) is


      iKey       NUMBER;

    BEGIN

      iKey := HashKey(itemType || name);
      waIND := iKey;

      if (Activities.EXISTS(iKey)) then --We found an Activity Record.

        /*========================================================+
         | We will validate the actdate against the Activity      |
         | record begin and end date to make sure we have the     |
         | proper version of the Activity in cache.               |
         +========================================================*/

        if ((actdate > Activities(iKey).begin_date) and
           ((Activities(iKey).END_DATE is Null) or
            (actdate < Activities(iKey).END_DATE))) then

          /*========================================================+
           | We have the proper version, now we will make sure we   |
           | have not encountered a hash collision.  (A condition   |
           | where the same HashKey has been generated for two      |
           | different records).                                    |
           +========================================================*/

          if ((itemType <> Activities(iKey).item_type) or
              (name <> Activities(iKey).name)) then
                raise WF_CACHE.HashCollision;

          else

            /*========================================================+
             | We have a good record and are ready to deliver the     |
             | waIND to the caller.                                   |
             +========================================================*/


             status := WF_CACHE.task_SUCCESS;



          end if;

        else -- Activity Record is not the proper version.

          status := WF_CACHE.task_FAILED;
          CacheManager(TAB_Activities);

        end if;

      else -- We did not find an Activity Record in cache.

          status := WF_CACHE.task_FAILED;
          CacheManager(TAB_Activities);

      end if;

    EXCEPTION
      when NO_DATA_FOUND then
        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_Activities);

      when HashCollision then
        if not (ErrorOnCollision) then
          status := WF_CACHE.task_FAILED;

        else
          raise;

        end if;

      when OTHERS then
        raise;

    END;


/*===========================+
 | GetActivityAttr           |
 +===========================+===================+
 | IN:   itemType   (VARCHAR2)                   |
 |       name       (VARCHAR2)                   |
 |       actid      (NUMBER)                     |
 |       actdate    (DATE)                       |
 +-----------------------------------------------+
 | OUT:  status     (PLS_INTEGER)                |
 |       wa_index   (NUMBER)                     |
 |       waa_index  (NUMBER)                     |
 +===============================================*/

   PROCEDURE GetActivityAttr ( itemType  in             VARCHAR2,
                               name      in             VARCHAR2,
                               actid     in             NUMBER,
                               actdate   in             DATE,
                               status    out    NOCOPY  PLS_INTEGER,
                               wa_index  out    NOCOPY  NUMBER,
                               waa_index out    NOCOPY  NUMBER) is

      l_endDate   DATE;
      l_WAindex   NUMBER;
      l_WAAindex  NUMBER;

      l_status    PLS_INTEGER;


    BEGIN
      WF_CACHE.GetProcessActivity(actid, l_status);

      -- First we will check to see if the ProcessActivity is in cache.
      -- Then we will use the ACTIVITY_NAME to check the other cache records.

      if (l_status <> WF_CACHE.task_SUCCESS) then
        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_ActivityAttributes);
        return;

      end if;

       l_WAAindex := HashKey(itemType || name ||
                             ProcessActivities(actid).ACTIVITY_NAME);


      -- Now that we have validated the ProcessActivity and Activity, we
      -- will check to see if the ActivityAttribute matches.
      if (ActivityAttributes.EXISTS(l_WAAindex)) then

      -- We will now check to see if we have an activity in cache that is the
      -- proper version.

      WF_CACHE.GetActivity( ProcessActivities(actid).ACTIVITY_ITEM_TYPE,
                            ProcessActivities(actid).ACTIVITY_NAME,
                            actdate, l_status, l_WAIndex );

      if (l_status <> WF_CACHE.task_SUCCESS) then
        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_ActivityAttributes);
        return;

      end if;


        if ( (ActivityAttributes(l_WAAindex).ACTIVITY_ITEM_TYPE <>
              Activities(l_WAindex).ITEM_TYPE)

              or

             (ActivityAttributes(l_WAAindex).ACTIVITY_NAME <>
              Activities(l_WAindex).NAME)

              or

             (ActivityAttributes(l_WAAindex).ACTIVITY_VERSION <>
              Activities(l_WAindex).VERSION) ) then

              CacheManager(TAB_ActivityAttributes);
              status := task_FAILED;
              return;

        else

             wa_index  := l_WAindex;
             waa_index := l_WAAindex;
             status    := task_SUCCESS;

        end if;

      else

        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_ActivityAttributes);

        return;

      end if;

    EXCEPTION
        when HashCollision then
          if not (ErrorOnCollision) then
              status := WF_CACHE.task_FAILED;
              CacheManager(TAB_ActivityAttributes);

          else
            raise;

          end if;

        when OTHERS then
          raise;

    END;





/*===========================+
 | GetActivityAttrValue      |
 +===========================+===================+
 | IN:   actID           (NUMBER)                |
 |       name            (VARCHAR2)              |
 +-----------------------------------------------+
 | OUT:  status          (PLS_INTEGER)           |
 |       waavIND         (NUMBER)                |
 +===============================================*/

   PROCEDURE GetActivityAttrValue (
                                  actid   in            NUMBER,
                                  name    in            VARCHAR2,
                                  status  out    NOCOPY PLS_INTEGER,
                                  waavIND out    NOCOPY NUMBER)
   is

      iKey       NUMBER;

    BEGIN

      iKey := HashKey(actid || name);
      waavIND := iKey;

      if (ActivityAttrValues.EXISTS(iKey)) then

        if ((actid <> ActivityAttrValues(iKey).process_activity_id) or
               (name <> ActivityAttrValues(iKey).name)) then
                raise HashCollision;

        else
          status :=  WF_CACHE.task_SUCCESS;

        end if;

      else
        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_ActivityAttrValues);

      end if;

    EXCEPTION
        when NO_DATA_FOUND then
            status := WF_CACHE.task_FAILED;
            CacheManager(TAB_ActivityAttrValues);

        when HashCollision then
          if not (ErrorOnCollision) then
            status := WF_CACHE.task_FAILED;
            CacheManager(TAB_ActivityAttrValues);

          else
            raise;

          end if;

        when OTHERS then
          raise;

    END;


/*===========================+
 | GetActivityTransitions    |
 +===========================+===================+
 | IN:   FromActID       (NUMBER)                |
 |       result          (VARCHAR2)              |
 +-----------------------------------------------+
 | OUT:  status          (PLS_INTEGER)           |
 |       watIND          (NUMBER)                |
 +===============================================*/

   PROCEDURE GetActivityTransitions (
                                FromActID in            NUMBER,
                                result    in            VARCHAR2,
                                status    out    NOCOPY PLS_INTEGER,
                                watIND    out    NOCOPY NUMBER )
  is
    iKey  NUMBER;

  begin
   iKey := WF_CACHE.HashKey(FromActID||':'|| result);
   watIND := iKey;

   if (WF_CACHE.ActivityTransitions.EXISTS(iKey)) then
     if ((WF_CACHE.ActivityTransitions(iKey).FROM_PROCESS_ACTIVITY <> FromActID)
      or (WF_CACHE.ActivityTransitions(iKey).RESULT_CODE not in
           (result, WF_ENGINE.eng_trans_default, WF_ENGINE.eng_trans_any))) then
        raise HashCollision;

     else
       status := WF_CACHE.task_SUCCESS;


     end if;

   else
     status := WF_CACHE.task_FAILED;
     CacheManager(TAB_ActivityTransitions);
   end if;

  exception
    when HashCollision then
      if not (ErrorOnCollision) then
        status := WF_CACHE.task_FAILED;
        --Normally we can just report a failure so the calling api will store
        --a new record in the current slot and move on.  However since
        --activity transitions are interrelated, we have to clear the whole
        --table to ensure consistency.  This condition should not occur in
        --normal processing and is just a safegard against the extreme.
        WF_CACHE.ActivityTransitions.DELETE;

      else
        raise;

      end if;

    when OTHERS then
      raise;

  end;


/*===========================+
 | GetItemAttribute          |
 +===========================+===================+
 | IN:   itemType         (VARCHAR2)             |
 |       name             (VARCHAR2)             |
 +-----------------------------------------------+
 | OUT:  status           (PLS_INTEGER)          |
 |       wiaIND           (NUMBER)               |
 +===============================================*/

   PROCEDURE GetItemAttribute (itemType in              VARCHAR2,
                               name     in              VARCHAR2,
                               status   out    NOCOPY   PLS_INTEGER,
                               wiaIND   out    NOCOPY   NUMBER) is

     iKey        NUMBER;

   BEGIN

     iKey := HashKey(itemType || name);
     wiaIND := iKey;

      if (ItemAttributes.EXISTS(iKey)) then

        if ((itemType <> ItemAttributes(iKey).item_type) or
            (name <> ItemAttributes(iKey).name)) then
          raise HashCollision;

        else
          status := WF_CACHE.task_SUCCESS;

        end if;

      else
        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_ItemAttributes);

      end if;

    EXCEPTION
        when NO_DATA_FOUND then
          status := WF_CACHE.task_FAILED;
          CacheManager(TAB_ItemAttributes);

        when HashCollision then
          if not (ErrorOnCollision) then
            status := WF_CACHE.task_FAILED;
            CacheManager(TAB_ItemAttributes);

          else
            raise;

          end if;

        when OTHERS then
          raise;

    END;


/*===========================+
 | GetItemAttrValue          |
 +===========================+===================+
 | IN:   itemType         (VARCHAR2)             |
 |       itemKey          (VARCHAR2)             |
 |       name             (VARCHAR2)             |
 +-----------------------------------------------+
 | OUT:  status           (PLS_INTEGER)          |
 |       wiavIND          (NUMBER)               |
 +-----------------------------------------------+
 | NOTE: Use in #SYNCH mode only.                |
 +===============================================*/

   PROCEDURE GetItemAttrValue (itemType in         VARCHAR2,
                               itemKey  in         VARCHAR2,
                               name     in         VARCHAR2,
                               status   out NOCOPY PLS_INTEGER,
                               wiavIND  out NOCOPY NUMBER) is

     ikey number;

   begin
   --ItemAttrValue cache is introduced in synch process only, so itemKey
   --will always be #SYNCH.  However, later when we introduce item locking
   --we will be able to cache attributes for multiple items.
     iKey := Hashkey(itemType||itemKey||name);
     wiavIND := iKey;

     if (ItemAttrValues.EXISTS(iKey)) then
       if ((ItemAttrValues(iKey).ITEM_TYPE <> itemType) or
           (ItemAttrValues(iKey).ITEM_KEY <> itemKey) or
           (ItemAttrValues(iKey).NAME <> name)) then
         raise hashcollision;

       else
         status := WF_CACHE.task_SUCCESS;

       end if;

     else
       status := WF_CACHE.task_FAILED;

     end if;

  exception
     when HashCollision then
       if not (ErrorOnCollision) then
         status := WF_CACHE.task_FAILED;

       else
         raise;

       end if;

   end;


/*===========================+
 | GetItemType               |
 +===========================+===================+
 | IN:   itemType        (VARCHAR2)              |
 +-----------------------------------------------+
 | OUT:  status      (PLS_INTEGER)               |
 |       witIND      (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetItemType (itemType in             VARCHAR2,
                          status   out    NOCOPY  PLS_INTEGER,
                          witIND   out    NOCOPY  NUMBER) is

      iKey        NUMBER;

    BEGIN

      iKey := HashKey(itemType);
      witIND := iKey;

      if (ItemTypes.EXISTS(iKey)) then
        if (itemType <> ItemTypes(iKey).name) then
                raise HashCollision;

        else

           status := WF_CACHE.task_SUCCESS;

        end if;

      else
        status := WF_CACHE.task_FAILED;
        CacheManager(TAB_ItemTypes);

      end if;

    EXCEPTION
        when NO_DATA_FOUND then
            status := WF_CACHE.task_FAILED;
            CacheManager(TAB_ItemTypes);

        when HashCollision then
          if not (ErrorOnCollision) then
            status := WF_CACHE.task_FAILED;
            CacheManager(TAB_ItemTypes);

          else
            raise;

          end if;

        when OTHERS then
          raise;


    END;


/*===========================+
 | GetProcessActivity        |
 +===========================+===================+
 | IN:   actid         (NUMBER)                  |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 +===============================================*/

   PROCEDURE GetProcessActivity (actid  in            NUMBER,
                                 status out    NOCOPY PLS_INTEGER) is


   BEGIN

     if (ProcessActivities.EXISTS(actid)) then

       status := WF_CACHE.task_SUCCESS;

     else
       status := WF_CACHE.task_FAILED;

     end if;

    EXCEPTION
     when NO_DATA_FOUND then
          status := WF_CACHE.task_FAILED;
          CacheManager(TAB_ProcessActivities);

     when OTHERS then
          raise;

    END;

/*===========================+
 | GetProcessActivityInfo    |
 +===========================+===================+
 | IN:   actid         (NUMBER)                  |
 |       actdate       (DATE)                    |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 |          waIND    (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetProcessActivityInfo (actid   in            NUMBER,
                                     actdate in            DATE,
                                     status  out    NOCOPY PLS_INTEGER,
                                     waIND   out    NOCOPY NUMBER) is

   l_status PLS_INTEGER;
   l_waIND  NUMBER;

   BEGIN

     if (ProcessActivities.EXISTS(actid)) then

       WF_CACHE.GetActivity(ProcessActivities(actid).ACTIVITY_ITEM_TYPE,
                            ProcessActivities(actid).ACTIVITY_NAME, actdate,
                            l_status, l_waIND);

       waIND := l_waIND;

       if ((l_status <> WF_CACHE.task_SUCCESS)

            or

           ((ProcessActivities(actid).ACTIVITY_ITEM_TYPE <>
            Activities(l_waIND).ITEM_TYPE) or

             (ProcessActivities(actid).ACTIVITY_NAME <>
              Activities(l_waIND).NAME)) ) then

         status := WF_CACHE.task_FAILED;
         CacheManager(TAB_Activities);
         CacheManager(TAB_ProcessActivities);
         return;

       else
         status := WF_CACHE.task_SUCCESS;

       end if;

     else
       status := WF_CACHE.task_FAILED;
       CacheManager(TAB_Activities);
       CacheManager(TAB_ProcessActivities);
       return;

     end if;

   EXCEPTION
     when NO_DATA_FOUND then
          status := WF_CACHE.task_FAILED;
          CacheManager(TAB_ProcessActivities);

     when OTHERS then
          raise;

   END;

/*===========================+
 | GetNLSParameter           |
 +===========================+===================+
 | IN:   Parameter   (VARCHAR2)                  |
 +-----------------------------------------------+
 | OUT:     status   (PLS_INTEGER)               |
 |          nlsIND   (NUMBER)                    |
 +===============================================*/

   PROCEDURE GetNLSParameter (Parameter  in            VARCHAR2,
                              status     out    NOCOPY PLS_INTEGER,
                              nlsIND     out    NOCOPY NUMBER) is
      iKey        NUMBER;

    BEGIN
      iKey := HashKey(Parameter);
      nlsIND := iKey;

      if (NLSParameters.EXISTS(iKey)) then
        if (Parameter <> NLSParameters(iKey).PARAMETER) then
                raise HashCollision;

        else
           status := WF_CACHE.task_SUCCESS;

        end if;

      else
        status := WF_CACHE.task_FAILED;
        --We do not really need to cache manage NLS Parameters, the plsql table
        --should remain small.

      end if;

    EXCEPTION
        when NO_DATA_FOUND then
            status := WF_CACHE.task_FAILED;

        when HashCollision then
          if not (ErrorOnCollision) then
            status := WF_CACHE.task_FAILED;

          else
            raise;

          end if;

        when OTHERS then
          raise;

    END;
--</rwunderl:2750876>
--<rwunderl:2412971>
/*===========================+
 | GetProcessStartActivities |
 +===========================+===================+
 | IN:    ItemType (VARCHAR2)                    |
 |        Name     (VARCHAR2)                    |
 |        Version  (NUMBER)                      |
 +-----------------------------------------------+
 | OUT:   status   (PLS_INTEGER)                 |
 |        spaIND   (NUMBER)                      |
 +===============================================*/

   PROCEDURE GetProcessStartActivities (ItemType   in            VARCHAR2,
                                        Name       in            VARCHAR2,
                                        Version    in            NUMBER,
                                        status     out    NOCOPY PLS_INTEGER,
                                        psaIND     out    NOCOPY NUMBER) is

      iKey        NUMBER;

    BEGIN
      iKey := HashKey(ItemType||':'||Name||':'||Version);
      psaIND := iKey;

      if (ProcessStartActivities.EXISTS(iKey)) then
        if ((ItemType <> ProcessStartActivities(iKey).PROCESS_ITEM_TYPE) or
            (Name <> ProcessStartActivities(iKey).PROCESS_NAME) or
            (Version <> ProcessStartActivities(iKey).PROCESS_VERSION)) then
                raise HashCollision;

        else
           status := WF_CACHE.task_SUCCESS;

        end if;

   else
     status := WF_CACHE.task_FAILED;
     CacheManager(TAB_ProcessStartActivities);
   end if;

  exception
    when HashCollision then
      if not (ErrorOnCollision) then
        status := WF_CACHE.task_FAILED;
        --Normally we can just report a failure so the calling api will store
        --a new record in the current slot and move on.  However since
        --starting process activites are interrelated, we have to clear the
        --whole table to ensure consistency.  This condition should not occur
        --in normal processing and is just a safegard against the extreme.
        WF_CACHE.ProcessStartActivities.DELETE;

      else
        raise;

      end if;

    when OTHERS then
      raise;
  end;
--</rwunderl:2412971>

--
-- BeginTransaction
-- (PRIVATE)
--  Begins a trusted session where calls to Reset() will not have any effect.
--  Caller has to call EndTransaction() immediately before issuing commit.
--  Returns FALSE if transaction was already begun by a parent call.
   FUNCTION BeginTransaction return BOOLEAN
   is
   begin
     if ((NOT trustedTransaction) or (trustedTransaction is NULL)) then
       trustedTransaction := TRUE;
       return TRUE; --Signal SUCCESS
     else
       return FALSE; --Signal that Transaction was already begun.
     end if;
   end;

--
-- EndTransaction
-- (PRIVATE)
-- Signals the end of a trusted session and calls Reset() to lock and update
-- WFCACHE_META_UPD.
--
   FUNCTION EndTransaction return BOOLEAN
   is
   begin
     if ((NOT trustedTransaction) or (trustedTransaction is NULL)) then
       Reset();  --We are going to call Reset() to clear any running caches.
       return FALSE; --Signal that there was no transaction to end.
     else
       trustedTransaction := FALSE;
       Reset();
       return TRUE;
     end if;
   end;

END WF_CACHE;


/
