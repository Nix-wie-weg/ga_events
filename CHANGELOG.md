# Changelog
All notable changes to this project will be documented in this file.
The format suggested at http://keepachangelog.com/ is used.

## 1.0.1 - 2014-04-29

### Fixed
- Universal Analytics Adapter now marks event as non-interaction.

## 1.1.0 - 2014-10-17

### Added
- Some documentation regarding controller specs (closes #10)
- More middleware specs

### Fixed
- Error returns white page

## 1.2.0 - 2014-12-18

### Added
- A Test Adapter that pushes events to a `window.events` array.

## 1.3.0 - 2017-04-27

### Added
- Support for turbolinks.

## 1.4.0 - 2018-03-09

### Fixed
- Fixed turbolinks events. To prevent older events the be processed again after page
  changes orchestrated by turbolinks, events are no longer processed via the
  injected DOM node. (Because the node would be cached and the event already
  processed.) Instead the the header-strategy is being used.

## 1.4.1 - 2018-04-03

### Fixed
- Ensure category, action and label do not include any umlauts or ß chars
- Fixed an error where events are remaining after a redirect

## 2.0.0 - 2020-11-20

### Removed
- Support for rubies < 2.3
- Support for rails < 4.2

### Added
- Compatibility for Rails 5

## 2.1.0 - 2021-09-07

### Added
- Optional user consent flag to prevent event flushing until consent was given

## 3.0.0 - 2022-01-10

### Added
- Universal Analytics Adapter can be configured to use `gtag.js` instead of
  `analytics.js` event syntax
  - [Breaking] The constructor interface has changed due to more configuration
    options that differ between `analytics.js` and `gtag.js`.
- Universal Analytics Adapter can be configured to use a custom name for the
  analytics object (defaults to `window.ga()` for `analytics.js` and
  `window.gtag()` for `gtag.js`)

## 4.0.0 - 2023-08-xx

### Added
  - Support for GA4 using the `GTagAdapter`

### Breaking
-  Dropped support for older rubies. The gem requires at least ruby 3.2 now
-  UniversalAnalyticsAdapter and GoogleAnalyticsAdapter removed
-  The `GaEvent::Event` constructor changed to conform to the new newer
GA4 event interface.

  ```ruby
  # 3.x and before
  GaEvents::Event.new('category', 'action', 'label', 'value')

  # 4.x onwards
  GaEvents::Event.new('event_name', {
    custom_dimension: 'xxx',
    custom_dimension2: 'yyy'
  })
  ```
- Events that should be kept on redirects are no longer mixed into rails
flashes. Redirect events are stored inside a custom rack session variable
instead.

