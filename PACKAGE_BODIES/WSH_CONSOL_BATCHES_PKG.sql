--------------------------------------------------------
--  DDL for Package Body WSH_CONSOL_BATCHES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_CONSOL_BATCHES_PKG" as
/* $Header: WSHTMCBB.pls 120.1 2005/09/08 14:03:10 wrudge noship $ */
	procedure INSERT_ROW (
	  X_ROWID in out nocopy VARCHAR2,
	  X_BATCH_ID in out nocopy NUMBER,
	  X_FREIGHT_TERMS_CODE in VARCHAR2,
	  X_CARRIER_ID in NUMBER,
	  X_MODE_OF_TRANSPORT in VARCHAR2,
	  X_SERVICE_LEVEL in VARCHAR2,
	  X_LOADING_SEQUENCE in NUMBER,
	  X_INTMED_SHIP_TO_LOCATION_ID in NUMBER,
	  X_ULTI_SHIP_TO_LOCATION_ID in NUMBER,
	  X_ULTI_SHIP_TO_REGION in NUMBER,
	  X_ULTI_SHIP_TO_ZIP_FROM in NUMBER,
	  X_ULTI_SHIP_TO_ZIP_TO in NUMBER,
	  X_ULTI_SHIP_TO_ZONE in NUMBER,
	  X_INCL_STAGED_DEL_FLAG in VARCHAR2,
	  X_INCL_DEL_ASG_TRIPS_FLAG in VARCHAR2,
	  X_CR_TRIP_TO_ULTM_SHIP_TO in VARCHAR2,
	  X_ROUTE_TRIPS_FLAG in VARCHAR2,
	  X_RATE_TRIPS_FLAG in VARCHAR2,
	  X_TRIP_NAME_PREFIX in VARCHAR2,
	  X_ORGANIZATION_ID in NUMBER,
	  X_CONSOL_GROUPING_RULE_ID in NUMBER,
	  X_CONSOL_SHIP_TO_LOCATION_ID in NUMBER,
	  X_DROPOFF_START_DAYS in NUMBER,
	  X_DELIVERY_NAME_TO in VARCHAR2,
	  X_PICKUP_START_DAYS in NUMBER,
	  X_PICKUP_END_DAYS in NUMBER,
	  X_CUSTOMER_ID in NUMBER,
	  X_FOB_CODE in VARCHAR2,
	  X_DELIVERY_NAME_FROM in VARCHAR2,
	  X_SHIP_TO_OVERIDE_FLAG in VARCHAR2,
	  X_DROPOFF_END_DAYS in NUMBER,
	  X_PR_BATCH_ID in NUMBER,
	  X_MAX_TRIP_WEIGHT in NUMBER,
	  X_MAX_TRIP_WEIGHT_UOM in VARCHAR2,
	  X_CREATION_DATE in DATE,
	  X_CREATED_BY in NUMBER,
	  X_LAST_UPDATE_DATE in DATE,
	  X_LAST_UPDATED_BY in NUMBER,
	  X_LAST_UPDATE_LOGIN in NUMBER
	) is
	  user_id  NUMBER;
	  login_id NUMBER;
	  l_batch_id  NUMBER;
	   CURSOR C IS SELECT rowid FROM WSH_CONSOL_BATCHES
	         WHERE batch_id = l_batch_id;
	  --
	  CURSOR NEXTID IS SELECT wsh_consol_batches_s.nextval FROM sys.dual;
	begin
	     user_id  := FND_GLOBAL.USER_ID;
	     login_id := FND_GLOBAL.LOGIN_ID;

	       IF (X_BATCH_ID is NULL) THEN
	     OPEN NEXTID;
	     FETCH NEXTID INTO l_batch_id;
	     CLOSE NEXTID;
	     END IF;
	  insert into WSH_CONSOL_BATCHES (
	    FREIGHT_TERMS_CODE,
	    CARRIER_ID,
	    MODE_OF_TRANSPORT,
	    SERVICE_LEVEL,
	    LOADING_SEQUENCE,
	    INTMED_SHIP_TO_LOCATION_ID,
	    ULTI_SHIP_TO_LOCATION_ID,
	    ULTI_SHIP_TO_REGION,
	    ULTI_SHIP_TO_ZIP_FROM,
	    ULTI_SHIP_TO_ZIP_TO,
	    ULTI_SHIP_TO_ZONE,
	    INCL_STAGED_DEL_FLAG,
	    INCL_DEL_ASG_TRIPS_FLAG,
	    CR_TRIP_TO_ULTM_SHIP_TO,
	    ROUTE_TRIPS_FLAG,
	    RATE_TRIPS_FLAG,
	    TRIP_NAME_PREFIX,
	    CREATION_DATE,
	    CREATED_BY,
	    LAST_UPDATE_DATE,
	    LAST_UPDATED_BY,
	    LAST_UPDATE_LOGIN,
	    BATCH_ID,
	    ORGANIZATION_ID,
	    CONSOL_GROUPING_RULE_ID,
	    CONSOL_SHIP_TO_LOCATION_ID,
	    DROPOFF_START_DAYS,
	    DELIVERY_NAME_TO,
	    PICKUP_START_DAYS,
	    PICKUP_END_DAYS,
	    CUSTOMER_ID,
	    FOB_CODE,
	    DELIVERY_NAME_FROM,
	    SHIP_TO_OVERIDE_FLAG,
	    DROPOFF_END_DAYS,
	    PR_BATCH_ID,
	    MAX_TRIP_WEIGHT,
	    MAX_TRIP_WEIGHT_UOM
	  ) values(
	    X_FREIGHT_TERMS_CODE,
	    X_CARRIER_ID,
	    X_MODE_OF_TRANSPORT,
	    X_SERVICE_LEVEL,
	    X_LOADING_SEQUENCE,
	    X_INTMED_SHIP_TO_LOCATION_ID,
	    X_ULTI_SHIP_TO_LOCATION_ID,
	    X_ULTI_SHIP_TO_REGION,
	    X_ULTI_SHIP_TO_ZIP_FROM,
	    X_ULTI_SHIP_TO_ZIP_TO,
	    X_ULTI_SHIP_TO_ZONE,
	    X_INCL_STAGED_DEL_FLAG,
	    X_INCL_DEL_ASG_TRIPS_FLAG,
	    X_CR_TRIP_TO_ULTM_SHIP_TO,
	    X_ROUTE_TRIPS_FLAG,
	    X_RATE_TRIPS_FLAG,
	    X_TRIP_NAME_PREFIX,
	    SYSDATE,
	    user_id,
	    SYSDATE,
	    user_id,
	    login_id,
	    l_batch_id,
	    X_ORGANIZATION_ID,
	    X_CONSOL_GROUPING_RULE_ID,
	    X_CONSOL_SHIP_TO_LOCATION_ID,
	    X_DROPOFF_START_DAYS,
	    X_DELIVERY_NAME_TO,
	    X_PICKUP_START_DAYS,
	    X_PICKUP_END_DAYS,
	    X_CUSTOMER_ID,
	    X_FOB_CODE,
	    X_DELIVERY_NAME_FROM,
	    X_SHIP_TO_OVERIDE_FLAG,
	    X_DROPOFF_END_DAYS,
	    X_PR_BATCH_ID,
	    X_MAX_TRIP_WEIGHT,
	    X_MAX_TRIP_WEIGHT_UOM);

	x_batch_id := l_batch_id;
	  /*open c;
	  fetch c into X_ROWID;
	  if (c%notfound) then
	    close c;
	    raise no_data_found;
	  end if;
	  close c;*/

	end INSERT_ROW;

	/*procedure LOCK_ROW (
	  X_BATCH_ID in NUMBER,
	  X_FREIGHT_TERMS_CODE in VARCHAR2,
	  X_CARRIER_ID in NUMBER,
	  X_MODE_OF_TRANSPORT in VARCHAR2,
	  X_SERVICE_LEVEL in VARCHAR2,
	  X_LOADING_SEQUENCE in NUMBER,
	  X_INTMED_SHIP_TO_LOCATION_ID in NUMBER,
	  X_ULTI_SHIP_TO_LOCATION_ID in NUMBER,
	  X_ULTI_SHIP_TO_REGION in NUMBER,
	  X_ULTI_SHIP_TO_ZIP_FROM in NUMBER,
	  X_ULTI_SHIP_TO_ZIP_TO in NUMBER,
	  X_ULTI_SHIP_TO_ZONE in NUMBER,
	  X_INCL_STAGED_DEL_FLAG in VARCHAR2,
	  X_INCL_DEL_ASG_TRIPS_FLAG in VARCHAR2,
	  X_CR_TRIP_TO_ULTM_SHIP_TO in VARCHAR2,
	  X_ROUTE_TRIPS_FLAG in VARCHAR2,
	  X_RATE_TRIPS_FLAG in VARCHAR2,
	  X_TRIP_NAME_PREFIX in VARCHAR2,
	  X_ORGANIZATION_ID in NUMBER,
	  X_CONSOL_GROUPING_RULE_ID in NUMBER,
	  X_CONSOL_SHIP_TO_LOCATION_ID in NUMBER,
	  X_DROPOFF_START_DAYS in NUMBER,
	  X_DELIVERY_NAME_TO in VARCHAR2,
	  X_PICKUP_START_DAYS in NUMBER,
	  X_PICKUP_END_DAYS in NUMBER,
	  X_CUSTOMER_ID in NUMBER,
	  X_FOB_CODE in VARCHAR2,
	  X_DELIVERY_NAME_FROM in VARCHAR2,
	  X_SHIP_TO_OVERIDE_FLAG in VARCHAR2,
	  X_DROPOFF_END_DAYS in NUMBER,
	  X_PR_BATCH_ID in NUMBER,
	  X_MAX_TRIP_WEIGHT in NUMBER,
	  X_MAX_TRIP_WEIGHT_UOM in VARCHAR2
	) is
	  cursor c1 is select
	      FREIGHT_TERMS_CODE,
	      CARRIER_ID,
	      MODE_OF_TRANSPORT,
	      SERVICE_LEVEL,
	      LOADING_SEQUENCE,
	      INTMED_SHIP_TO_LOCATION_ID,
	      ULTI_SHIP_TO_LOCATION_ID,
	      ULTI_SHIP_TO_REGION,
	      ULTI_SHIP_TO_ZIP_FROM,
	      ULTI_SHIP_TO_ZIP_TO,
	      ULTI_SHIP_TO_ZONE,
	      INCL_STAGED_DEL_FLAG,
	      INCL_DEL_ASG_TRIPS_FLAG,
	      CR_TRIP_TO_ULTM_SHIP_TO,
	      ROUTE_TRIPS_FLAG,
	      RATE_TRIPS_FLAG,
	      TRIP_NAME_PREFIX,
	      ORGANIZATION_ID,
	      CONSOL_GROUPING_RULE_ID,
	      CONSOL_SHIP_TO_LOCATION_ID,
	      DROPOFF_START_DAYS,
	      DELIVERY_NAME_TO,
	      PICKUP_START_DAYS,
	      PICKUP_END_DAYS,
	      CUSTOMER_ID,
	      FOB_CODE,
	      DELIVERY_NAME_FROM,
	      SHIP_TO_OVERIDE_FLAG,
	      DROPOFF_END_DAYS,
	      PR_BATCH_ID,
	      BATCH_ID
	    from WSH_CONSOL_BATCHES
	    where BATCH_ID = X_BATCH_ID
	    for update of BATCH_ID nowait;
	begin

	  OPEN C;
	  FETCH C INTO Recinfo;
	  --
	  if (C%NOTFOUND) then
	    --
	    CLOSE C;
	    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_DELETED');
	    APP_EXCEPTION.Raise_Exception;
	    --
	  end if;
	  --
	  IF C%ISOPEN THEN
	    CLOSE C;
	  END IF;

	      if (    ((recinfo.BATCH_ID = X_BATCH_ID)
	          AND ((recinfo.FREIGHT_TERMS_CODE = X_FREIGHT_TERMS_CODE)
	               OR ((recinfo.FREIGHT_TERMS_CODE is null) AND (X_FREIGHT_TERMS_CODE is null)))
	          AND ((recinfo.CARRIER_ID = X_CARRIER_ID)
	               OR ((recinfo.CARRIER_ID is null) AND (X_CARRIER_ID is null)))
	          AND ((recinfo.MODE_OF_TRANSPORT = X_MODE_OF_TRANSPORT)
	               OR ((recinfo.MODE_OF_TRANSPORT is null) AND (X_MODE_OF_TRANSPORT is null)))
	          AND ((recinfo.SERVICE_LEVEL = X_SERVICE_LEVEL)
	               OR ((recinfo.SERVICE_LEVEL is null) AND (X_SERVICE_LEVEL is null)))
	          AND ((recinfo.LOADING_SEQUENCE = X_LOADING_SEQUENCE)
	               OR ((recinfo.LOADING_SEQUENCE is null) AND (X_LOADING_SEQUENCE is null)))
	          AND ((recinfo.INTMED_SHIP_TO_LOCATION_ID = X_INTMED_SHIP_TO_LOCATION_ID)
	               OR ((recinfo.INTMED_SHIP_TO_LOCATION_ID is null) AND (X_INTMED_SHIP_TO_LOCATION_ID is null)))
	          AND ((recinfo.ULTI_SHIP_TO_LOCATION_ID = X_ULTI_SHIP_TO_LOCATION_ID)
	               OR ((recinfo.ULTI_SHIP_TO_LOCATION_ID is null) AND (X_ULTI_SHIP_TO_LOCATION_ID is null)))
	          AND ((recinfo.ULTI_SHIP_TO_REGION = X_ULTI_SHIP_TO_REGION)
	               OR ((recinfo.ULTI_SHIP_TO_REGION is null) AND (X_ULTI_SHIP_TO_REGION is null)))
	          AND ((recinfo.ULTI_SHIP_TO_ZIP_FROM = X_ULTI_SHIP_TO_ZIP_FROM)
	               OR ((recinfo.ULTI_SHIP_TO_ZIP_FROM is null) AND (X_ULTI_SHIP_TO_ZIP_FROM is null)))
	          AND ((recinfo.ULTI_SHIP_TO_ZIP_TO = X_ULTI_SHIP_TO_ZIP_TO)
	               OR ((recinfo.ULTI_SHIP_TO_ZIP_TO is null) AND (X_ULTI_SHIP_TO_ZIP_TO is null)))
	          AND ((recinfo.ULTI_SHIP_TO_ZONE = X_ULTI_SHIP_TO_ZONE)
	               OR ((recinfo.ULTI_SHIP_TO_ZONE is null) AND (X_ULTI_SHIP_TO_ZONE is null)))
	          AND ((recinfo.INCL_STAGED_DEL_FLAG = X_INCL_STAGED_DEL_FLAG)
	               OR ((recinfo.INCL_STAGED_DEL_FLAG is null) AND (X_INCL_STAGED_DEL_FLAG is null)))
	          AND ((recinfo.INCL_DEL_ASG_TRIPS_FLAG = X_INCL_DEL_ASG_TRIPS_FLAG)
	               OR ((recinfo.INCL_DEL_ASG_TRIPS_FLAG is null) AND (X_INCL_DEL_ASG_TRIPS_FLAG is null)))
	          AND ((recinfo.CR_TRIP_TO_ULTM_SHIP_TO = X_CR_TRIP_TO_ULTM_SHIP_TO)
	               OR ((recinfo.CR_TRIP_TO_ULTM_SHIP_TO is null) AND (X_CR_TRIP_TO_ULTM_SHIP_TO is null)))
	          AND ((recinfo.ROUTE_TRIPS_FLAG = X_ROUTE_TRIPS_FLAG)
	               OR ((recinfo.ROUTE_TRIPS_FLAG is null) AND (X_ROUTE_TRIPS_FLAG is null)))
	          AND ((recinfo.RATE_TRIPS_FLAG = X_RATE_TRIPS_FLAG)
	               OR ((recinfo.RATE_TRIPS_FLAG is null) AND (X_RATE_TRIPS_FLAG is null)))
	          AND ((recinfo.TRIP_NAME_PREFIX = X_TRIP_NAME_PREFIX)
	               OR ((recinfo.TRIP_NAME_PREFIX is null) AND (X_TRIP_NAME_PREFIX is null)))
	          AND ((recinfo.ORGANIZATION_ID = X_ORGANIZATION_ID)
	               OR ((recinfo.ORGANIZATION_ID is null) AND (X_ORGANIZATION_ID is null)))
	          AND ((recinfo.CONSOL_GROUPING_RULE_ID = X_CONSOL_GROUPING_RULE_ID)
	               OR ((recinfo.CONSOL_GROUPING_RULE_ID is null) AND (X_CONSOL_GROUPING_RULE_ID is null)))
	          AND ((recinfo.CONSOL_SHIP_TO_LOCATION_ID = X_CONSOL_SHIP_TO_LOCATION_ID)
	               OR ((recinfo.CONSOL_SHIP_TO_LOCATION_ID is null) AND (X_CONSOL_SHIP_TO_LOCATION_ID is null)))
	          AND ((recinfo.DROPOFF_START_DAYS = X_DROPOFF_START_DAYS)
	               OR ((recinfo.DROPOFF_START_DAYS is null) AND (X_DROPOFF_START_DAYS is null)))
	          AND ((recinfo.DELIVERY_NAME_TO = X_DELIVERY_NAME_TO)
	               OR ((recinfo.DELIVERY_NAME_TO is null) AND (X_DELIVERY_NAME_TO is null)))
	          AND ((recinfo.PICKUP_START_DAYS = X_PICKUP_START_DAYS)
	               OR ((recinfo.PICKUP_START_DAYS is null) AND (X_PICKUP_START_DAYS is null)))
	          AND ((recinfo.PICKUP_END_DAYS = X_PICKUP_END_DAYS)
	               OR ((recinfo.PICKUP_END_DAYS is null) AND (X_PICKUP_END_DAYS is null)))
	          AND ((recinfo.CUSTOMER_ID = X_CUSTOMER_ID)
	               OR ((recinfo.CUSTOMER_ID is null) AND (X_CUSTOMER_ID is null)))
	          AND ((recinfo.FOB_CODE = X_FOB_CODE)
	               OR ((recinfo.FOB_CODE is null) AND (X_FOB_CODE is null)))
	          AND ((recinfo.DELIVERY_NAME_FROM = X_DELIVERY_NAME_FROM)
	               OR ((recinfo.DELIVERY_NAME_FROM is null) AND (X_DELIVERY_NAME_FROM is null)))
	          AND ((recinfo.SHIP_TO_OVERIDE_FLAG = X_SHIP_TO_OVERIDE_FLAG)
	               OR ((recinfo.SHIP_TO_OVERIDE_FLAG is null) AND (X_SHIP_TO_OVERIDE_FLAG is null)))
	          AND ((recinfo.DROPOFF_END_DAYS = X_DROPOFF_END_DAYS)
	               OR ((recinfo.DROPOFF_END_DAYS is null) AND (X_DROPOFF_END_DAYS is null)))
	          AND ((recinfo.PR_BATCH_ID = X_PR_BATCH_ID)
	               OR ((recinfo.PR_BATCH_ID is null) AND (X_PR_BATCH_ID is null)))
	          AND ((recinfo.MAX_TRIP_WEIGHT = X_MAX_TRIP_WEIGHT)
	               OR ((recinfo.MAX_TRIP_WEIGHT is null) AND (X_MAX_TRIP_WEIGHT is null)))
	          AND ((recinfo.MAX_TRIP_WEIGHT_UOM = X_MAX_TRIP_WEIGHT_UOM)
	               OR ((recinfo.MAX_TRIP_WEIGHT_UOM is null) AND (X_MAX_TRIP_WEIGHT_UOM is null)))
	      ) then
	        null;
	      else
	        fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
	        app_exception.raise_exception;
	      end if;
	  return;
	end LOCK_ROW;*/
END WSH_CONSOL_BATCHES_PKG;

/
