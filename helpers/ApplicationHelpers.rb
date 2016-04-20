module ApplicationHelpers

  def erb_with_binding(template, vars)
    ERB.new(template).result(OpenStruct.new(vars).instance_eval { binding })
  end

  def country_name
    {
      'de' => 'Germany',
      'us' => 'the United States of America',
      'gb' => 'United Kindom',
      'nl' => 'Netherlands',
      'be' => 'Belgium',
      'at' => 'Austria',
      'au' => 'Australia'
    }   
  end

  def date_of_last_week_monday
    Date.parse('Monday') > Date.today ? Date.parse('Monday') - 14 : Date.parse('Monday') - 7
  end

  def date_of_this_week_monday
    Date.parse('Monday') > Date.today ? Date.parse('Monday') - 7 : Date.parse('Monday')
  end

  def date_of_this_week_tuesday
    Date.parse('Tuesday') > Date.today ? Date.parse('Tuesday') - 7 : Date.parse('Tuesday')
  end

  def date_of_this_week_sunday
    Date.parse('Sunday') < Date.today ? Date.parse('Sunday') + 7 : Date.parse('Sunday')
  end

  def date_of_this_week_saturday
    Date.parse('Saturday') < Date.today ? Date.parse('Saturday') - 7 : Date.parse('Saturday')
  end

  def current_week
    week_w_format(DateTime.now)
  end 

  def iso_year_week_array
     iso_year_week.map { |key, value| key }
  end

  def forecast_week
    Hash[*((1..8).map {|index| [week_w_format(DateTime.now + index * 7), week_format(DateTime.now + index * 7)]}.flatten)]
  end

  def historical_weeks
    Hash[*((1..20).map {|index| [date_of_this_week_saturday - index * 7, week_format(date_of_this_week_saturday - index * 7)]}.flatten)]
  end

  def iso_year_week
    Hash[*((0..200).map {|index| [week_w_format(DateTime.now + index * 7), week_format(DateTime.now + index * 7)]}.flatten)]
  end

  def week_w_format(date)
    date.cwyear.to_s + '-W' +  date.cweek.to_s.to_s.rjust(2, "0")
  end

  def week_format(date)
    date.cwyear.to_s + '-' +  date.cweek.to_s.rjust(2, "0")
  end

  def bigquery_sql(dataset, from, to)
    offset = ((Date.parse from) - 30).strftime("%Y-%m-%d")
    sql = <<-EOC
    SELECT
      today.order_nr AS conversion_id,
      past.source AS source,
      past.medium AS medium,
      past.keyword AS keyword,
      past.campaign AS campaign,
      past.visitNumber AS visitNumber,
      past.visitor AS visitor_id,
      reset.offsetVisit AS offsetVisit 
    FROM (
      SELECT
        fullVisitorId AS visitor,
        MIN(visitNumber) AS visitNumber,
        trafficSource.medium AS medium,
        hits.transaction.transactionId AS order_nr
      FROM
        TABLE_DATE_RANGE([#{dataset}.ga_sessions_], TIMESTAMP('#{from}'), TIMESTAMP('#{to}'))
      WHERE
        hits.transaction.transactionId IS NOT NULL
      GROUP BY
        visitor,
        order_nr,
        medium) AS today
    LEFT JOIN (
      SELECT
        fullVisitorId AS visitor,
        visitNumber AS visitNumber,
        trafficSource.medium AS medium,
        trafficSource.source AS source,
        trafficSource.keyword AS keyword,
        trafficSource.campaign AS campaign
      FROM
        TABLE_DATE_RANGE([#{dataset}.ga_sessions_], TIMESTAMP('#{offset}'), TIMESTAMP('#{to}'))) AS past
    ON
      past.visitor = today.visitor
    LEFT JOIN (
      SELECT 
        fullVisitorId AS visitor,
        min(visitNumber)-1 AS offsetVisit
      FROM 
        TABLE_DATE_RANGE([#{dataset}.ga_sessions_], TIMESTAMP('#{offset}'), TIMESTAMP('#{to}'))
      GROUP BY
        visitor
    ) AS reset
    ON
      today.visitor = reset.visitor 
    WHERE
      past.visitNumber <= today.visitNumber
    ORDER BY
      conversion_id,
      visitNumber
    EOC
    sql
  end

end
