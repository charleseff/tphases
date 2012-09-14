tphases
=======

TPhases (Transactional Phases) is a support framework that helps you build your Rails request life cycles into read-only and write-only phases.

The way it accomplishes this is with the methods `TPhases.read_phase` and `TPhases.write_phase` which takes blocks.  Here is a simple example inside of a controller action:

```ruby
class BarsController < ApplicationController

  def update
    TPhases.read_phase do
      @bar = Bar.find(params[:id])
    end
    
    TPhases.write_phase do
      @bar.update_attributes(params[:bar])
    end

    redirect_to @bar
  end
end
```