{% if var('BingSearchQueryPerformanceReport') %}
    {{ config( enabled = True ) }}
{% else %}
    {{ config( enabled = False ) }}
{% endif %}

{% if var('currency_conversion_flag') %}
-- depends_on: {{ ref('ExchangeRates') }}
{% endif %}

{# /*--calling macro for tables list and remove exclude pattern */ #}
{% set result =set_table_name("BingSearchQueryPerformanceReport_tbl_ptrn","BingSearchQueryPerformanceReport_tbl_exclude_ptrn") %}
{# /*--iterating through all the tables */ #}
{% for i in result %}

    select 
    {{ extract_brand_and_store_name_from_table(i, var('brandname_position_in_tablename'), var('get_brandname_from_tablename_flag'), var('default_brandname')) }} as brand,
    {{ extract_brand_and_store_name_from_table(i, var('storename_position_in_tablename'), var('get_storename_from_tablename_flag'), var('default_storename')) }} as store,
    AccountId,
    AccountName,
    AccountNumber,
    AccountStatus ,
    AdGroupCriterionId ,
    AdGroupId ,
    AdGroupName ,
    AdGroupStatus ,
    AdId,
    AdStatus ,
    AdType,
    Assists ,
    AverageCpc ,
    AveragePosition ,
    BidMatchType,
    CampaignId ,
    CampaignName  ,
    CampaignStatus ,
    CampaignType  ,
    cast(Clicks as BIGINT) as Clicks ,
    ConversionRate ,
    cast(Conversions as numeric) as Conversions,
    CostPerAssist ,
    CostPerConversion ,
    Ctr ,
    CustomerId ,
    CustomerName ,
    DeliveredMatchType,
    DestinationUrl ,
    DeviceOS,
    DeviceType,
    Impressions ,
    Keyword ,
    KeywordId,
    KeywordStatus ,
    Language ,
    Network,
    ReturnOnAdSpend ,
    Revenue ,
    RevenuePerAssist ,
    RevenuePerConversion ,
    SearchQuery,
    cast(Spend as numeric) as Spend ,
    {{timezone_conversion("TimePeriod")}} as TimePeriod,
    TopVsOther,
    {{daton_user_id()}} as _daton_user_id,
    {{daton_batch_runtime()}} as _daton_batch_runtime,
    {{daton_batch_id()}} as _daton_batch_id,            
    current_timestamp() as _last_updated,
    '{{env_var("DBT_CLOUD_RUN_ID", "manual")}}' as _run_id
    from {{i}} a    
        {% if is_incremental() %}
            {# /* -- this filter will only be applied on an incremental run */ #}
            where {{daton_batch_runtime()}}  >= (select coalesce(max(_daton_batch_runtime) - {{ var('BingSearchQueryPerformanceReport_lookback') }},0) from {{ this }})
            --WHERE 1=1
        {% endif %}
    Qualify ROW_NUMBER() OVER (PARTITION BY AccountNumber,AdId,TopVsOther,DeviceOS,Network,DeviceType,KeywordId,SearchQuery,BidMatchType,DeliveredMatchType,TimePeriod order by {{daton_batch_runtime()}} desc) = 1
{% if not loop.last %} union all {% endif %}
{% endfor %}
