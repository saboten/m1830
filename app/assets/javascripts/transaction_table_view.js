//Static contents for displaying various corporation inputs. Used inside table tags. Inserted via javascript.
//TODO Consider rendering this file using a partial.
var tableInteriorHtml = {
  FINAL_SCORE : "<tr>\
                   <th>Final Value</th>\
                 </tr>\
                 <tr>\
                   <td><input class='transaction_input' name='final_value' type='text' value='0'></td>\
                 </tr>",
  BUY_SELL : "<tr>\
                <th>Quantity</td>\
                <th>Value</td>\
              </tr>\
              <tr>\
                <td><input class='transaction_input' id='share_quantity' name='share_quantity' type='text' value='1'></td>\
                <td><input class='transaction_input' id='share_value' name='share_value' type='text' value='0'></td>\
              </tr>\
              <tr>\
                <td colspan='2'>\
                  <a href='#' class='transaction_button' id='source_button'>Initial Offering</a>\
                </td>\
              </tr>\
              <tr>\
                <td colspan='2'>\
                  <a href='#' class='transaction_button_left' id='buy_button'>(B)uy</a><!--\
                  --><a href='#' class='transaction_button_right' id='sell_button'>(S)ell</a>\
                </td>\
              </tr>",
  RUN : "<tr>\
           <th>Value</th>\
         </tr>\
         <tr>\
           <td><input class='transaction_input' id='run_value' name='run_value' type='text' value='0'></td>\
         </tr>\
         <tr>\
           <td><a href='#' class='transaction_button_left' id='withhold_button'>(W)ithhold</a><!--\
           --><a href='#' class='transaction_button_right' id='pay_button'>(P)ay out</a></td>\
         </tr>"
};